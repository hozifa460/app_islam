"""YouTube sync — generates 3 SEPARATE files per channel
(<categoryId>.live.json / .videos.json / .shorts.json) and auto-updates
index.json. Also deletes the OLD single <categoryId>.youtube.json file
(if present) and removes its path from index.json.

Each file matches the RecitationCategory schema (same `id`), so the Dart
cascade merge in `_fetchYouTubeChannels` automatically concatenates the
`items[]` arrays from the 3 files into one in-memory category.

Used by both GitHub Actions (.github/workflows/youtube-sync.yml) and
GitLab CI (radio_islam/.gitlab-ci.yml).

Idempotent: re-runs are safe.
  - If a file already exists, it is overwritten with fresh RSS data.
  - If a path is already in index.json, it is NOT re-added.
  - Old .youtube.json files are removed in the same commit.

Classification (same logic as Dart `parseYouTubeRss`):
  - Shorts: title contains "shorts" / "شورتس" / "شورت" / "#short"
  - Live:   title contains "live" / "بث" / "مباشر" / "لايف" / "on air"
            AND not negated by "not live" / "ليس بث" / "لا بث" / "غير مباشر"
  - Videos: everything else
"""
import sys
import io

if sys.platform == "win32":
    try:
        sys.stdout = io.TextIOWrapper(
            sys.stdout.buffer, encoding="utf-8", errors="replace"
        )
        sys.stderr = io.TextIOWrapper(
            sys.stderr.buffer, encoding="utf-8", errors="replace"
        )
    except Exception:
        pass

import argparse
import json
import re
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Dict, List, Optional

NS = {"atom": "http://www.w3.org/2005/Atom"}


# ══════════════════════════════════════════════════════════
#  Classification helpers (mirror Dart `parseYouTubeRss`)
# ══════════════════════════════════════════════════════════

_SHORTS_RE = re.compile(r"(?:^|#|-\s*)shorts?\b|#short|شورتس|شورت")


def _is_shorts(title: str) -> bool:
    return bool(_SHORTS_RE.search(title.lower()))


_LIVE_NEG_RE = re.compile(r"not\s+live|ليس\s+بث|لا\s+بث|غير\s*مباشر")
# بث ككلمة مستقلة: يطابق "بث طاريء" / "بث عاجل" / "بث مباشر" / "البث" / "بث حي"
_LIVE_RE = re.compile(
    r"\b(live|streaming|live\s*now|live\s*stream|on\s*air|stream)\b"
    r"|\bبث\b"
    r"|ال\s*بث"
    r"|لايف"
    r"|مباشر"
    r"|على\s*الهواء"
)


def _is_live(title: str) -> bool:
    lower = title.lower()
    if _LIVE_NEG_RE.search(lower):
        return False
    return bool(_LIVE_RE.search(lower))


# ══════════════════════════════════════════════════════════
#  Folder / RSS / entries
# ══════════════════════════════════════════════════════════

def detect_folder(cwd):
    """Detect data folder from CWD. Prefer --folder if given."""
    if (cwd / "radio_database").exists():
        return "radio_database"
    if (cwd / "radio_islam").exists():
        return "radio_islam"
    raise SystemExit(
        "Cannot detect data folder (no radio_database/ or radio_islam/). "
        "Pass --folder explicitly."
    )


def fetch_rss(channel_id):
    url = f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    rss = urllib.request.urlopen(req, timeout=15).read()
    return ET.fromstring(rss)


def fetch_tab_ids(channel_id):
    """Fetch YouTube auto-generated playlist IDs for Live (UULV) and Shorts
    (UUSH) tabs using the channel's RSS feed and the tab URL patterns.

    Returns dict with 'live' and 'shorts' keys, each a set of videoIds, or
    empty sets if the tab playlist is unreachable."""
    live_ids: set[str] = set()
    shorts_ids: set[str] = set()

    # Extract the channel base identifier after UC prefix
    # Channel ID: UCxxxxxxxxx → rest = xxxxxxxxx
    rest = channel_id.removeprefix("UC")
    if not rest:
        return {"live": live_ids, "shorts": shorts_ids}

    base_url = "https://www.youtube.com/feeds/videos.xml?playlist_id="
    for tab_prefix, dest in [("UULV", live_ids), ("UUSH", shorts_ids)]:
        playlist_id = f"{tab_prefix}{rest}"
        url = f"{base_url}{playlist_id}"
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            root = ET.fromstring(urllib.request.urlopen(req, timeout=15).read())
            for entry in root.findall("atom:entry", NS):
                vid_el = entry.find("atom:id", NS)
                if vid_el is not None and vid_el.text:
                    vid = vid_el.text.split(":")[-1]
                    if vid:
                        dest.add(vid)
        except Exception as exc:
            print(f"  [WARN] tab playlist {playlist_id}: {exc}")
    return {"live": live_ids, "shorts": shorts_ids}


def fetch_video_metadata(video_ids: List[str]) -> Dict[str, Dict[str, Any]]:
    """Fetch real YouTube metadata (is_live, live_status, duration) for each
    video using yt-dlp. Returns dict mapping videoId → metadata.

    Falls back to empty dict on import error or fetch failure (CI then uses
    title heuristics as a fallback).
    """
    out: Dict[str, Dict[str, Any]] = {}
    try:
        from yt_dlp import YoutubeDL  # type: ignore
    except ImportError:
        print("[WARN] yt-dlp not installed, falling back to title heuristics")
        return out
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "skip_download": True,
        "extract_flat": False,
        "ignoreerrors": True,
    }
    try:
        with YoutubeDL(ydl_opts) as ydl:
            for vid in video_ids:
                url = f"https://www.youtube.com/watch?v={vid}"
                try:
                    info = ydl.extract_info(url, download=False) or {}
                    out[vid] = {
                        "is_live": info.get("is_live", False),
                        "live_status": info.get("live_status"),
                        "duration": info.get("duration"),  # seconds or None
                        "is_short": info.get("is_short", False),
                    }
                except Exception as e:
                    print(f"  [WARN] yt-dlp {vid}: {e}")
    except Exception as e:
        print(f"[WARN] yt-dlp global error: {e}")
    return out


def entries_to_subitems(root, channel_name, limit=15):
    """Return list of subItem dicts (videoId, title, etc.) — unclassified."""
    subitems = []
    for entry in root.findall("atom:entry", NS)[: limit * 3]:
        # Pull `limit*3` so we have enough for each bucket after classification
        vid_el = entry.find("atom:id", NS)
        title_el = entry.find("atom:title", NS)
        if vid_el is None or title_el is None:
            continue
        vid = vid_el.text.split(":")[-1] if vid_el.text else ""
        if not vid:
            continue
        title = title_el.text or ""
        subitems.append({"videoId": vid, "title": title})
    return subitems


def build_subitem(video_id: str, title: str, channel_name: str,
                   is_live: bool = False, duration_seconds: int = None) -> dict:
    youtube_url = f"https://www.youtube.com/watch?v={video_id}"
    item = {
        "title": title,
        "subtitle": channel_name,
        "emoji": "",
        "audioUrl": youtube_url,
        "imageUrl": f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg",
        "videoUrl": youtube_url,
        "videoSource": "youtube",
        "mediaType": "both",
    }
    if is_live:
        item["isLive"] = True
    if duration_seconds is not None:
        item["durationSeconds"] = duration_seconds
    return item


def classify_subitems(
    raw_items, channel_name, limit, metadata_map=None,
    tab_live_ids=None, tab_shorts_ids=None,
):
    """Split raw RSS entries into 3 buckets: live / videos / shorts.

    Priority (most authoritative first):
    1. UULV playlist contains videoId → 'live'
    2. UUSH playlist contains videoId → 'shorts'
    3. Metadata-based: is_live/live_status → 'live'
    4. Metadata-based: is_short → 'shorts'
    5. Title heuristics → 'shorts' / 'live'
    6. Long duration (>1h) + not_live → 'live' (recorded broadcast)
    7. Default → 'videos'
    """
    tab_live = tab_live_ids or set()
    tab_shorts = tab_shorts_ids or set()
    live, videos, shorts = [], [], []
    for entry in raw_items:
        vid = entry["videoId"]
        meta = (metadata_map or {}).get(vid) if metadata_map else None
        is_live = False
        duration_seconds = None
        if meta:
            is_live = meta.get("is_live", False) or meta.get("live_status") in ("is_live", "was_live")
            duration_seconds = meta.get("duration")
        sub = build_subitem(vid, entry["title"], channel_name,
                            is_live=is_live, duration_seconds=duration_seconds)
        bucket = classify_one(
            vid=vid, title=entry["title"], meta=meta,
            tab_live_ids=tab_live, tab_shorts_ids=tab_shorts,
        )
        if bucket == "shorts" and len(shorts) < limit:
            shorts.append(sub)
        elif bucket == "live" and len(live) < limit:
            live.append(sub)
        elif len(videos) < limit:
            videos.append(sub)
    return live, videos, shorts


def classify_one(
    vid: str, title: str, meta=None,
    tab_live_ids=None, tab_shorts_ids=None,
) -> str:
    """Classify a single video into 'live' / 'videos' / 'shorts'.

    Priority:
    1. UULV playlist contains videoId → 'live'  (YouTube authoritative)
    2. UUSH playlist contains videoId → 'shorts' (YouTube authoritative)
    3. is_live=True or live_status='is_live'/'was_live' → 'live'
    4. is_short → 'shorts'
    5. Title-based shorts fallback
    6. Long (>1h) + not_live → 'live' (recorded broadcast)
    7. Title-based live fallback
    8. Default → 'videos'
    """
    tab_live = tab_live_ids or set()
    tab_shorts = tab_shorts_ids or set()
    # 1. UULV authoritative live
    if vid in tab_live:
        return "live"
    # 2. UUSH authoritative shorts
    if vid in tab_shorts:
        return "shorts"
    if meta:
        is_live = meta.get("is_live")
        live_status = meta.get("live_status")
        duration_sec = meta.get("duration")
        is_short = meta.get("is_short", False)
        # 3. Metadata: live
        if is_live is True or live_status in ("is_live", "was_live"):
            return "live"
        # 4. Metadata: short
        if is_short:
            return "shorts"
        # 5. Title-based shorts
        if _is_shorts(title):
            return "shorts"
        # 6. Long recorded broadcast
        if live_status == "not_live" and duration_sec is not None and duration_sec > 3600:
            return "live"
        # 7. Title-based live
        if _is_live(title):
            return "live"
    else:
        # No metadata, fallback to title heuristics
        if _is_shorts(title):
            return "shorts"
        if _is_live(title):
            return "live"
    # 8. Default
    return "videos"


# ══════════════════════════════════════════════════════════
#  File builders
# ══════════════════════════════════════════════════════════

def _base_category(category_id, channel_name):
    return {
        "id": category_id,
        "title": channel_name,
        "emoji": "🎥",
        "description": f"فيديوهات قناة {channel_name} على يوتيوب",
        "gradientColors": ["#8B0000", "#FF6347"],
        "imageUrl": "",
    }


def build_live_file(category_id, channel_name, subitems):
    return {
        **_base_category(category_id, channel_name),
        "items": [
            {
                "title": f"بثوث مباشرة — {channel_name}",
                "subtitle": "يوتيوب",
                "emoji": "🔴",
                "imageUrl": "",
                "audioUrl": "",
                "subItems": subitems,
            }
        ],
    }


def build_videos_file(category_id, channel_name, subitems):
    return {
        **_base_category(category_id, channel_name),
        "items": [
            {
                "title": f"فيديوهات {channel_name}",
                "subtitle": "يوتيوب",
                "emoji": "🎙️",
                "imageUrl": "",
                "audioUrl": "",
                "subItems": subitems,
            }
        ],
    }


def build_shorts_file(category_id, channel_name, subitems):
    return {
        **_base_category(category_id, channel_name),
        "items": [
            {
                "title": f"شورتس — {channel_name}",
                "subtitle": "يوتيوب",
                "emoji": "📱",
                "imageUrl": "",
                "audioUrl": "",
                "subItems": subitems,
            }
        ],
    }


# ══════════════════════════════════════════════════════════
#  Main
# ══════════════════════════════════════════════════════════

def load_or_init_index(index_path):
    if not index_path.exists():
        return {"files": []}
    return json.loads(index_path.read_text(encoding="utf-8"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--folder", default=None, help="radio_database or radio_islam"
    )
    parser.add_argument(
        "--limit", type=int, default=15, help="Max items per type per channel"
    )
    args = parser.parse_args()

    cwd = Path.cwd()
    folder = args.folder or detect_folder(cwd)
    print(f"[INFO] Data folder: {folder}")

    manifest_path = cwd / folder / "youtube_channels.json"
    if not manifest_path.exists():
        print(f"[ERROR] Manifest not found: {manifest_path}")
        sys.exit(1)

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    channels = manifest.get("channels", [])
    if not channels:
        print("[INFO] No channels in manifest, nothing to do")
        sys.exit(0)

    print(f"[INFO] {len(channels)} channel(s) in manifest")

    index_path = cwd / folder / "index.json"
    index_data = load_or_init_index(index_path)
    existing_files = set(index_data.get("files", []))
    index_changed = False
    files_to_delete = []  # old .youtube.json to remove

    for ch in channels:
        category_id = ch.get("categoryId", "").strip()
        channel_id = ch.get("channelId", "").strip()
        channel_name = ch.get("channelName", category_id).strip()

        if not category_id or not channel_id or "xxxxx" in channel_id:
            print(f"[SKIP] {category_id or '<no id>'}: incomplete config")
            continue

        try:
            root = fetch_rss(channel_id)
            print(f"[OK] {category_id}: RSS fetched")
        except Exception as e:
            print(f"[ERROR] {category_id}: RSS fetch failed: {e}")
            continue

        raw = entries_to_subitems(root, channel_name, limit=args.limit)
        if not raw:
            print(f"[WARN] {category_id}: no entries, skipping")
            continue
        # Fetch YouTube auto-generated tab playlists (UULV for Live, UUSH for Shorts)
        print(f"  [INFO] fetching tab playlists (UULV/UUSH)...")
        tab_ids = fetch_tab_ids(channel_id)
        tab_live_count = len(tab_ids.get("live", set()))
        tab_shorts_count = len(tab_ids.get("shorts", set()))
        print(
            f"  [INFO] live tab: {tab_live_count} videos, "
            f"shorts tab: {tab_shorts_count} videos"
        )
        # Fetch real YouTube metadata via yt-dlp for accurate classification
        video_ids = [r["videoId"] for r in raw]
        print(f"  [INFO] fetching yt-dlp metadata for {len(video_ids)} videos...")
        metadata_map = fetch_video_metadata(video_ids)
        if metadata_map:
            print(f"  [INFO] yt-dlp: {len(metadata_map)}/{len(video_ids)} succeeded")
        else:
            print("  [INFO] yt-dlp unavailable, using title heuristics")
        live, videos, shorts = classify_subitems(
            raw, channel_name, args.limit, metadata_map=metadata_map,
            tab_live_ids=tab_ids.get("live"),
            tab_shorts_ids=tab_ids.get("shorts"),
        )
        print(
            f"  [INFO] classified: live={len(live)} "
            f"videos={len(videos)} shorts={len(shorts)}"
        )

        channel_dir = cwd / folder / category_id
        channel_dir.mkdir(parents=True, exist_ok=True)

        # 1) Mark old single .youtube.json for deletion (transition period)
        #    - Always remove the index entry, even if file is already gone
        #    - Delete the file from disk if it still exists
        old_file = channel_dir / f"{category_id}.youtube.json"
        old_rel = f"{category_id}/{category_id}.youtube.json"
        if old_file.exists():
            files_to_delete.append(old_file)
        if old_rel in existing_files:
            existing_files.discard(old_rel)
            index_data["files"] = [
                f for f in index_data.get("files", []) if f != old_rel
            ]
            index_changed = True
            print(f"  [INFO] removed legacy {old_rel} from index.json")

        # 2) Write up to 3 files (only if non-empty)
        buckets = [
            ("live", "🔴", live, build_live_file),
            ("videos", "🎙️", videos, build_videos_file),
            ("shorts", "📱", shorts, build_shorts_file),
        ]
        for kind, emoji, subs, builder in buckets:
            if not subs:
                print(f"  [SKIP] {kind}: empty")
                continue
            file_path = channel_dir / f"{category_id}.{kind}.json"
            payload = builder(category_id, channel_name, subs)
            file_path.write_text(
                json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            rel_path = f"{category_id}/{category_id}.{kind}.json"
            print(
                f"  [OK] {rel_path}: {len(subs)} subItems {emoji}"
            )
            if rel_path in existing_files:
                print(f"  [INFO] index.json: {rel_path} already present")
            else:
                index_data.setdefault("files", []).append(rel_path)
                existing_files.add(rel_path)
                index_changed = True
                print(f"  [OK] index.json: added {rel_path}")

    # 3) Delete old .youtube.json files
    for old in files_to_delete:
        try:
            old.unlink()
            print(f"  [DEL] {old.relative_to(cwd)}")
        except Exception as e:
            print(f"  [WARN] could not delete {old}: {e}")

    # 4) Finalize index.json
    if index_changed:
        index_data["files"] = sorted(set(index_data["files"]))
        index_path.write_text(
            json.dumps(index_data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(
            f"\n[OK] index.json updated "
            f"({len(index_data['files'])} files)"
        )
    else:
        print("\n[INFO] index.json unchanged")

    print("\n[DONE] Sync complete")


if __name__ == "__main__":
    main()
