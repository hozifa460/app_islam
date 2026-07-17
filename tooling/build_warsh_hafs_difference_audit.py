"""Build a provenance-labelled Warsh/Hafs comparison from Quranpedia exports.

The exports identify both editions as matching the King Fahd Complex printed
Mushaf.  This tool deliberately does not infer a reading rule: it only records
the verse-level textual differences present in the two supplied editions.
"""

from __future__ import annotations

import argparse
import datetime as dt
import difflib
import hashlib
import json
import unicodedata
from pathlib import Path


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def comparable(text: str) -> str:
    """Keep only base Arabic letters and ordinary spaces for textual matching."""
    normalized = unicodedata.normalize("NFD", text)
    kept = []
    for char in normalized:
        codepoint = ord(char)
        if unicodedata.category(char).startswith("M") or 0x06D6 <= codepoint <= 0x06ED:
            continue
        if codepoint in (0x0640, 0xFEFF):
            continue
        # The two editions encode hamzat al-wasl differently.  It is not a
        # Hafs/Warsh textual difference, so compare it as a plain alif.
        kept.append("ا" if char == "ٱ" else char)
    return " ".join("".join(kept).split())


def words_for_surah(surah: dict) -> list[dict[str, object]]:
    words: list[dict[str, object]] = []
    for ayah in surah["ayahs"]:
        for index, word in enumerate(comparable(ayah["text"]).split()):
            words.append(
                {
                    "word": word,
                    "key": f"{ayah['surah']}:{ayah['number']}",
                    "wordIndex": index,
                    "page": ayah["page_number"],
                }
            )
    return words


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hafs", type=Path, required=True)
    parser.add_argument("--warsh", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    hafs_source = load(args.hafs)
    warsh_source = load(args.warsh)
    differences: list[dict[str, object]] = []
    total_warsh_ayahs = 0
    for hafs_surah, warsh_surah in zip(hafs_source["surahs"], warsh_source["surahs"]):
        total_warsh_ayahs += len(warsh_surah["ayahs"])
        hafs_words = words_for_surah(hafs_surah)
        warsh_words = words_for_surah(warsh_surah)
        matcher = difflib.SequenceMatcher(
            a=[word["word"] for word in hafs_words],
            b=[word["word"] for word in warsh_words],
            autojunk=False,
        )
        for tag, hafs_start, hafs_end, warsh_start, warsh_end in matcher.get_opcodes():
            if tag == "equal":
                continue
            changes = {
                "operation": tag,
                "surah": warsh_surah["id"],
                "hafsWords": hafs_words[hafs_start:hafs_end],
                "warshWords": warsh_words[warsh_start:warsh_end],
            }
            differences.append(changes)

    result = {
        "schemaVersion": 1,
        "generatedAt": dt.datetime.now(dt.timezone.utc).isoformat(),
        "reading": "Warsh an Nafi / al-Azraq compared with Hafs an Asim",
        "method": "Surah-level base-letter word alignment; diacritics, Quranic annotation signs, and encoding differences of hamzat al-wasl are excluded from the comparison.",
        "source": {
            "provider": "Quranpedia API",
            "hafs": {
                "endpoint": "https://api.quranpedia.net/v1/mushafs/1",
                "description": hafs_source["description"],
                "sha256": sha256(args.hafs),
            },
            "warsh": {
                "endpoint": "https://api.quranpedia.net/v1/mushafs/4",
                "description": warsh_source["description"],
                "sha256": sha256(args.warsh),
            },
            "secondaryReference": "الفارق بين رواية ورش وحفص — أعمر بن محمد بوبا الجكني",
        },
        "warshAyahCount": total_warsh_ayahs,
        "differenceCount": len(differences),
        "differences": differences,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps({"warshAyahCount": total_warsh_ayahs, "differenceCount": len(differences)}))


if __name__ == "__main__":
    main()
