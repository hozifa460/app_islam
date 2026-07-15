# PROJECT_MAP.md

آخر تحديث: 2026-06-28 — تحويل الصفحة الرئيسية للتلاوات إلى كروت كاتيغوري تفتح تفاصيل الشيخ عند الضغط.

## نظرة عامة
تطبيق إسلامي شامل (Flutter) — Android/iOS. يتعامل مع: الفتاوى، الراديو، القنوات، المكتبة، أوقات الصلاة، والأذكار.

---

## 1. تدفّق البيانات — الراديو (Radio Cascade)

`lib/screens/radio/data/recitation_categories_data.dart:63` — `initialize()`

```
[1] cache      → device_storage/recitations_cache/*.json
[2] assets     → assets/json/recitations/*.json
[3] remote     → GitHub: radio_database/
                  → GitLab: radio_islam/  (fallback)
[4] YouTube    → مدمج في [3] كـ 3 ملفات منفصلة بنفس `id`:
                  - `<categoryId>.live.json`   (بثوث مباشرة 🔴)
                  - `<categoryId>.videos.json` (فيديوهات 🎙️)
                  - `<categoryId>.shorts.json` (شورتس 📱)
                  الـ cascade يدمج items[] من الـ 3 ملفات تلقائياً.
```

كل مرحلة تستبدل الكاتيغوريز الموجودة (replace by id) ثم تضيف الجديد.

### Cooldowns (داخل الجلسة الواحدة)
| المصدر | المدة | الحقل |
|---|---|---|
| GitHub/GitLab (mp3) | 60 دقيقة | `_lastRemoteSync` |
| YouTube videos | 1 ساعة | `_lastYouTubeSync` |

`refreshRemote: true` يتجاوز الـ cooldown (يُستخدم في `reload()` و `forceRefresh()`).

---

## 2. الـ Models (الراديو)

`lib/screens/radio/models/recitation_models.dart`

| Class | الوصف |
|---|---|
| `RecitationCategory` | كاتيغوري رئيسي (مثل: "الشيخ المنشاوي") |
| `RecitationItem` | عنصر داخل الكاتيغوري (سورة/فيديو) |
| `RecitationSubItem` | عنصر فرعي داخل الـ item |
| `RecitationSubSection` | قسم فرعي |
| `MediaType` enum | `audio` / `video` / `both` |
| `VideoSource` enum | `direct` / `youtube` / `tiktok` |

دوال مساعدة: `_str`, `_strOrNull`, `_parseList`, `_parseColors`, `_tryParseColor`, `_parseVideoSource`, `_parseMediaType`, `detectVideoSource`.

---

## 3. الـ Cascade — ملفات الـ JSON

### Schema (لكل كاتيغوري)
```json
{
  "id": "menshawy",
  "title": "...",
  "emoji": "📖",
  "description": "...",
  "gradientColors": ["#2D1B69", "#7C3AED"],
  "imageUrl": null,
  "items": [
    {
      "title": "...",
      "subtitle": "...",
      "emoji": "...",
      "imageUrl": null,
      "imageAsset": null,
      "audioUrl": null,
      "videoUrl": "https://...",
      "videoSource": "youtube",
      "mediaType": "video",
      "subItems": [],
      "subSections": []
    }
  ]
}
```

### YouTube videos — 3 ملفات منفصلة بنفس بنية الـ RecitationCategory

```
radio_database/
├── 1_menshawy.json                 (mp3)
├── ...
├── zein_khair_allah/
│   ├── zein_khair_allah.json       (mp3 — schema قديم، 859KB)
│   ├── zein_khair_allah.live.json   (YouTube بثوث مباشرة 🔴 — قد يكون غائباً لو لا بثوث)
│   ├── zein_khair_allah.videos.json (YouTube فيديوهات 🎙️ — الملف الرئيسي)
│   └── zein_khair_allah.shorts.json (YouTube شورتس 📱 — قد يكون غائباً لو لا شورتس)
├── ...
└── youtube_channels.json           (manifest: 2 قناة نشطة)
```

**بنية كل ملف** (تطابق RecitationCategory، نفس `id` بين الملفات الـ 3):
```json
{
  "id": "zein_khair_allah",
  "title": "الشيخ زين خير الله",
  "emoji": "🎥",
  "description": "فيديوهات قناة الشيخ زين خير الله على يوتيوب",
  "gradientColors": ["#8B0000", "#FF6347"],
  "imageUrl": "",
  "items": [
    {
      "title": "فيديوهات الشيخ زين خير الله",   // أو "بثوث مباشرة — ..." أو "شورتس — ..."
      "subtitle": "يوتيوب",
      "emoji": "🎙️",                            // أو 🔴 أو 📱
      "imageUrl": "",
      "audioUrl": "",
      "subItems": [
        {
          "title": "حوارات ساخنة مع النصارى والملحدين",
          "subtitle": "الشيخ زين خير الله",
          "emoji": "",
          "audioUrl": "https://www.youtube.com/watch?v=IUb04k5uikh",
          "imageUrl": "https://i.ytimg.com/vi/IUb04k5uikh/hqdefault.jpg",
          "videoUrl": "https://www.youtube.com/watch?v=IUb04k5uikh",
          "videoSource": "youtube",
          "mediaType": "both"
        }
      ]
    }
  ]
}
```

> **آخر تحديث (2026-06-07)**: البنية عادت إلى 3 ملفات منفصلة بدلاً من ملف واحد. السبب: المستخدم يريد رؤية المجموعات الـ 3 (🔴/🎙️/📱) كـ items[] منفصلة في الواجهة. كل ملف له نفس `id` فالـ cascade يدمج items[] من الـ 3 ملفات في كاتيغوري واحدة في الذاكرة. الملفات الفارغة (بدون بثوث أو بدون شورتس) لا تُكتب.

### Manifest file (`youtube_channels.json`)
```json
{
  "version": 1,
  "channels": [
    { "categoryId": "zein_khair_allah", "channelId": "UCQKqsmz6fY_4l5ilNpJ5iSw", "channelName": "الشيخ زين خير الله" },
    { "categoryId": "haytham_talaat",  "channelId": "UCLj8UFOcdFrvlh24Lw7jrgA", "channelName": "الدكتور هيثم طلعت" }
  ]
}
```

> **الحالة الحالية (2026-06-07)**: الـ manifest فيه 2 قناة نشطة. الـ CI يقرأها ويولّد حتى 3 ملفات لكل قناة بناءً على التصنيف.

> لإضافة قناة جديدة: أضف entry في `youtube_channels.json` — الـ CI سيتولى الباقي خلال 3 ساعات (أو شغّل workflow يدوياً).

---

## 4. عناوين الريموت

| المورد | GitHub | GitLab |
|---|---|---|
| Index | `radio_database/index.json` | `radio_islam/index.json` |
| Base | `radio_database/` | `radio_islam/` |
| YouTube | `radio_database/<id>.{live,videos,shorts}.json` | `radio_islam/<id>.{live,videos,shorts}.json` |

URLs معرفة كثوابت في `recitation_categories_data.dart:18-30`.

---

## 5. الملفات الرئيسية (Radio)

| الملف | الدور |
|---|---|
| `recitation_categories_data.dart` | الـ singleton + cascade |
| `recitation_models.dart` | الـ DTOs |
| `radio_data.dart` | `RadioStationsData.all` (القرّاء) |
| `radio_station.dart` | نموذج محطة الراديو |
| `recitations_screen.dart` | شاشة الكاتيغوريز |
| `radio_screen.dart` | شاشة الراديو الرئيسية |
| `services/audio_coordinator.dart` | إدارة التشغيل المتزامن ومؤقت النوم وسرعة التشغيل |
| `services/shared_audio_player.dart` | مشغل الصوت المشترك (Singleton) لتوفير موارد النظام |

## 5ب. الملف المشترك — مشغل يوتيوب موحد

| الملف | الدور |
|---|---|
| `lib/core/video/shared_youtube_player.dart` | `SharedYoutubePlayer` — مشغل يوتيوب موحد مع تحكمات كاملة (Play/Pause، Seek +/-10s، Fullscreen، Settings للجودة والترجمة، Progress Bar) |
| `lib/screens/radio/video/youtube_video_screen.dart` | `YoutubeVideoScreen` — شاشة كاملة لعرض فيديو يوتيوب داخل التطبيق مع دعم الوضع الأفقي |
| `lib/screens/radio/video/helpers/video_launcher.dart` | `VideoLauncher` — يُشغّل يوتيوب عبر `YoutubeVideoScreen` (داخل التطبيق) والفيديو المباشر عبر `VideoPlayerScreen`/`VideoFeedScreen` |

يستخدمه:
- `lib/screens/radio/widgets/youtube_player_widget.dart` (عبر `bottomWidget` للعنوان + زر التحميل)
- `lib/screens/channels/video_player_screen.dart` (TODO: قيد الترحيل)

---

## 6. YouTube Sync — التفاصيل (3 ملفات منفصلة + auto-index)

> **آخر تحديث: 2026-06-07** — البنية: 3 ملفات منفصلة لكل قناة (`.live.json` / `.videos.json` / `.shorts.json`) بنفس `RecitationCategory` schema. الـ CI يحدّث `index.json` تلقائياً ويحذف ملف `.youtube.json` القديم (الفترة الانتقالية) إن وُجد.

### الملفات المُعدَّلة
- `lib/screens/radio/data/recitation_categories_data.dart` — `_fetchYouTubeChannels` يقرأ 3 ملفات لنفس `id` ويدمج `items[]`، `_syncWithRemoteStreaming` يتخطى `.youtube.json`/`.live.json`/`.videos.json`/`.shorts.json`.
- `lib/screens/radio/models/recitation_models.dart` (لا تغييرات)

### Script
- `tools/youtube_sync/sync_youtube.py` — Python يستخدمه CI
  - يقرأ `youtube_channels.json` (manifest)
  - لكل قناة: يجلب RSS، يصنّف إلى 3 buckets (live/videos/shorts)، يكتب ملف لكل bucket غير فارغ بنفس `RecitationCategory` schema
  - يحذف ملف `<categoryId>.youtube.json` القديم (الفترة الانتقالية)
  - يحدّث `index.json` تلقائياً (idempotent — re-runs آمنة)
  - يفحص `xxxxx` كـ placeholder لتخطي القنوات غير المهيأة

### بنية كل ملف (مثال: `zein_khair_allah.videos.json`)
```json
{
  "id": "zein_khair_allah",
  "title": "الشيخ زين خير الله",
  "emoji": "🎥",
  "description": "فيديوهات قناة الشيخ زين خير الله على يوتيوب",
  "gradientColors": ["#8B0000", "#FF6347"],
  "imageUrl": "",
  "items": [
    {
      "title": "فيديوهات الشيخ زين خير الله",
      "subtitle": "يوتيوب",
      "emoji": "🎙️",
      "imageUrl": "",
      "audioUrl": "",
      "subItems": [
        {
          "title": "حوارات ساخنة مع النصارى والملحدين",
          "subtitle": "الشيخ زين خير الله",
          "emoji": "",
          "audioUrl": "https://www.youtube.com/watch?v=IUb04k5uikh",
          "imageUrl": "https://i.ytimg.com/vi/IUb04k5uikh/hqdefault.jpg",
          "videoUrl": "https://www.youtube.com/watch?v=IUb04k5uikh",
          "videoSource": "youtube",
          "mediaType": "both"
        }
      ]
    }
  ]
}
```

**الفروق بين الـ 3 ملفات** (نفس البنية، يختلف items[0]):
- `.live.json`   → `emoji: "🔴"`, title `"بثوث مباشرة — <channelName>"`
- `.videos.json` → `emoji: "🎙️"`, title `"فيديوهات <channelName>"`
- `.shorts.json` → `emoji: "📱"`, title `"شورتس — <channelName>"`

**مفاتيح الـ subItem المهمة**:
- `audioUrl` = YouTube watch URL (الـ player يقرأه أولاً)
- `videoUrl` = YouTube watch URL (نفسه)
- `videoSource` = `"youtube"` (يحدد الـ widget)
- `mediaType` = `"both"` (صوت + فيديو معاً)

### التصنيف (نفس منطق Dart)
- 🔴 **بثوث مباشرة** — `live` / **`بث` ككلمة مستقلة** (يطابق "بث طاريء"، "بث عاجل"، "بث مباشر"، "البث"، "بث حي") / `لايف` / `على الهواء`. مع نفي: "not live" / "ليس بث" → يروح لفيديوهات
- 🎙️ **فيديوهات** — كل شيء آخر
- 📱 **شورتس** — `#shorts` / `شورتس` / `شورت`

> **ملاحظة Dart**: `\b` في Dart لا يعالج الحروف العربية حتى مع `unicode: true`. الحيلة: استخدام `(?<!\p{L})بث(?!\p{L})` (مع `unicode: true`) للتعرف على "بث" ككلمة مستقلة. الـ Python يستخدم `\b` مباشرة (يدعم Unicode افتراضياً).

### المصدر
- YouTube RSS Feed الرسمي: `https://www.youtube.com/feeds/videos.xml?channel_id=X`
- مجاني 100%، بدون API key، بدون quota
- آخر 15 فيديو فقط لكل قناة (الـ script يسحب `limit*3` ثم يصنّف)

### CI/CD
- **GitHub Actions**: `.github/workflows/youtube-sync.yml` — cron `0 * * * *`
  - يستدعي `python3 tools/youtube_sync/sync_youtube.py --folder radio_database`
  - `git add radio_database/` و commit و push
- **GitLab CI**: `radio_islam/.gitlab-ci.yml`
  - يستدعي `python3 tools/youtube_sync/sync_youtube.py --folder radio_islam`
  - `git add radio_islam/` و commit و push
- **حماية التضارب**: ملف `.sync.lock` بسيط — يخرج لو موجود
- **Idempotency**: إعادة تشغيل CI آمنة — لا يضيف entry مكرر لـ `index.json`، لا يحذف ملف موجود
- **جدولة**: كل 3 ساعات تلقائياً، أو يدوياً عبر `workflow_dispatch` / GitLab UI

### إضافة قناة جديدة (تلقائي 100%)
1. أضف entry جديد في `youtube_channels.json`:
   ```json
   { "categoryId": "mufti_menk", "channelId": "UCxxx", "channelName": "Mufti Menk" }
   ```
2. الـ CI يكتشفها خلال 3 ساعات (أو شغّل يدوياً عبر Actions/CI)
3. **تلقائياً**:
   - يُنشئ حتى 3 ملفات (`<id>.live.json` / `.videos.json` / `.shorts.json`) — فقط غير الفارغة
   - يضيف الـ paths لـ `index.json`
   - **يحذف legacy entries** من `index.json` (يدوم حذف ملف `<id>.youtube.json` بعد الفترة الانتقالية حتى لو الملف ما عاد موجوداً على القرص)
   - يرفع التغيير لـ GitHub + GitLab
4. التطبيق يقرأ `index.json` عند كل فتح → تظهر القناة تلقائياً
5. **لا تغيير كود في التطبيق مطلوب** — المنطق يقرأ كل ما في `index.json`

### زر التحديث اليدوي (Refresh Now) — Live Mode

> **آخر تحديث: 2026-06-07** — الزر يستدعي `_refreshLiveYouTube` (RSS مباشر) بدلاً من قراءة الملفات الثابتة.

- **التراكم (Accumulation)**: عند كل refresh، الفيديوهات الجديدة تنضاف **بدون حذف القديمة** (طالما الـ IDs ما تكررت). النتيجة: 15 → 16 → 17 ... مع الوقت. مرجع: `mergeYouTubeItems()` + `_videoIdFromUrl()`.
- **حد YouTube RSS**: YouTube يرجع آخر 15 فيديو فقط. مع التراكم، التطبيق يحتفظ بأكثر من 15 عبر الـ refreshات المتتالية.
- **التصنيف (3 ملفات منفصلة)**: كل قناة → حتى 3 ملفات (live/videos/shorts). نفس منطق Python `classify_subitems` + Dart `parseYouTubeRss`:
  - 🔴 `.live.json` — `live` / `بث مباشر` / `لايف` / `على الهواء` (مع نفي: "not live" / "ليس بث" → يروح لفيديوهات)
  - 🎙️ `.videos.json` — كل شيء آخر
  - 📱 `.shorts.json` — `#shorts` / `شورتس` / `شورت`
- **التصنيف بالـ metadata (CI فقط، yt-dlp)**: `classify_bucket_by_metadata(title, is_live, live_status, duration, is_short)` — أولوية: 1) `is_live`/`was_live` → live، 2) `is_short` → shorts، 3) title shorts → shorts، 4) `duration > 3600s` + not_live → live، 5) title بث → live، 6) default → videos. YouTube RSS ما يعطيش `live_status`/`duration` — `yt-dlp` يحل هذا (مجاني + غير محدود). النتيجة: `zein_khair_allah` يفترق 9 بثوث (حوارات/اتصالات) + 6 فيديوهات (بدلاً من 15 فيديو واحد). مرجع: `tools/youtube_sync/sync_youtube.py:fetch_video_metadata()` + `tools/requirements.txt:yt-dlp>=2024.1.0`.

- **الموقع**: 
  - `lib/screens/radio/recitations_screen.dart` — `AppBar.actions` (أيقونة `🔄` في الأعلى يمين)
  - `lib/screens/radio/radio_screen.dart` — `IconButton` بجوار زر الرجوع
- **السلوك**:
  1. يقرأ `youtube_channels.json` (manifest) من GitHub → GitLab
  2. لكل قناة في الـ manifest: يجلب RSS مباشرة من YouTube
  3. يدمج الفيديوهات الجديدة في الكاتيغوري فوراً
  4. يخزّن الكاتيغوري المدمج في الكاش (`youtube_*.json`)
  5. يحدث الواجهة (`_streamController.add`)
- **يتجاوز**:
  - Cooldown الـ 1 ساعة (`_lastYouTubeSync = null`)
  - ملفات `.youtube.json` الثابتة (يجلب RSS مباشر)
- **ثبات البيانات**: بعد إعادة تشغيل التطبيق، يتم تحميل `youtube_*.json` من الكاش بعد الـ assets مباشرة (`_loadCachedYouTubeCategories`) — لذا تبقى فيديوهات الـ refresh محفوظة دون الحاجة لإعادة الضغط على الزر.
- **Snackbar**: 
  - نجاح: `✓ تم تحديث فيديوهات يوتيوب` (أخضر `#2E7D32`)
  - فشل: `✗ فشل التحديث — تحقق من الاتصال` (أحمر `#C62828`)
- **دوال داخلية**:
  - `forceRefreshYouTube()` — wrapper عام (يُستدعى من الزر)
  - `_refreshLiveYouTube({int limit = 15})` — التنفيذ الفعلي
  - `parseYouTubeRss({xmlBody, channelName, limit})` — parser XML → `RecitationItem` (مكشوف للاختبار بـ `@visibleForTesting`)

### الاختبارات
- `test/youtube_refresh_test.dart` — 10 tests:
  - `parseYouTubeRss`: استخراج videoId/title، احترام limit، XML فارغ/معطوب
  - `parseYouTubeRss`: تصنيف shorts/live منفصل، نفي "not live" → videos
  - `classifyBucketByMetadata` (7 tests): أولوية live من metadata > shorts من metadata > title shorts > long+not_live=live > title live > default videos
  - `mergeYouTubeItems`: dedup by videoId، الجديد أولاً + القديم غير الموجود
- `test_youtube_metadata.py` — 8 tests لـ `classify_bucket_by_metadata` (Python، unittest)

---

## 7. Download Service (Strategy Pattern)

> **آخر تحديث: 2026-06-08** — إعادة هيكلة `YoutubeDownloadService` (903→403 سطر) باستخدام Strategy pattern + Invidious API.

### العمارة

```
services/download/
├── models/
│   ├── download_status.dart           # YoutubeDownloadStatus enum
│   ├── video_quality_option.dart      # VideoQualityOption
│   └── download_info.dart             # YoutubeDownloadInfo
│
├── strategies/
│   ├── download_strategy.dart         # Abstract interface 
│   ├── http_downloader.dart           # HTTP streaming + progress + cancel (مشترك)
│   ├── invidious_api.dart             # Invidious API client (instance fallback)
│   ├── youtube_strategy.dart          # YouTube: youtube_explode → Invidious → Cobalt
│   ├── tiktok_strategy.dart           # TikTok: tikwm.com → direct HTTP
│   └── direct_strategy.dart           # Direct: HTTP download
│
services/youtube_download_service.dart  # Orchestrator (SharedPrefs + dispatching)
```

### YouTube Strategy — سلسلة الاحتياطي (Fallback Chain)

| الرتبة | المصدر | الجودة القصوى | الصوت | الميزة |
|--------|--------|---------------|-------|--------|
| 1 | **youtube_explode_dart** (muxed) | 720p | ✅ مدمج | يعمل داخل التطبيق، يحاول عدة clients |
| 2 | **youtube_explode_dart** (videoOnly + audioOnly) | 4K | ✅ بعد الدمج | فيديو mp4 + أفضل صوت m4a ثم دمج بـ MediaMuxer |
| 3 | **Invidious API** (formatStreams/adaptiveFormats) | 1080p/4K | ✅ مدمج/منفصل | fallback عبر instances عامة |
| 4 | **Cobalt API** | max | ✅ مدمج | fallback أخير من خدمة عامة |
| 5 | **Direct URL من نافذة الجودة** | حسب الرابط | حسب المصدر | fallback أخير فقط إذا فشلت الاستراتيجية وكان الرابط متاحاً |

### نظام تحميل يوتيوب النهائي بدون سيرفر (2026-06-15)

- **القرار**: مسار يوتيوب أصبح `strategy-first`: `youtube_explode` أولاً، ثم `Invidious`، ثم `Cobalt`، ثم `directDownloadUrl` كآخر fallback فقط. TikTok و direct video لا يتغيران.
- **سبب القرار**: الرابط المباشر من نافذة الجودة قد يكون مؤقتاً/محجوباً. الاعتماد عليه أولاً كان يحول التحميل إلى `error` قبل تجربة المصادر الأقوى.
- **تطبيع الجودة**: `YouTubeStrategy.normalizedQualityForDownload()` تزيل suffix مثل `_merged` حتى تتحول `1080p_merged` إلى `1080p` عند البحث في streams.
- **الجودات العالية**: إذا اختار `youtube_explode` مسار `VideoOnlyStreamInfo`، يتم تحميل أفضل صوت `m4a` ثم الدمج عبر `VideoMergeUtil.mergeVideoAudio()` و Android MediaMuxer.
- **الرابط المباشر**: `YoutubeDownloadService` يستخدم `directDownloadUrl` كآخر fallback ليوتيوب فقط بعد فشل `YouTubeStrategy`، مع حذف ملفات الفيديو/الصوت المؤقتة عند الفشل.
- **Logging**: إضافة رسائل `debugPrint` لكل مصدر: `youtube_explode`, `Invidious`, `Cobalt`, direct fallback، مع تسجيل سبب الفشل.
- **اختبار**: `test/youtube_download_strategy_test.dart` يغطي تطبيع جودة `_merged` وترتيب fallback (`youtube_explode` → `invidious` → `cobalt`).
- **الملفات المتأثرة**: `quality_picker_sheet.dart` + `youtube_download_service.dart` + `youtube_strategy.dart`.

### دمج الفيديو + الصوت (Native MediaMuxer)

- بدلاً من مكتبة FFmpeg (~30MB) التي توقفت نهائياً، يُستخدم Android `MediaMuxer` API الأصلي عبر MethodChannel
- يعيد تثبيت المسارات دون إعادة تشفير (remux) → سريع جداً
- الكود: `android/.../VideoMergerPlugin.kt` ← Dart: `lib/services/video_merge_util.dart`
- **هام**: يعمل فقط مع MP4 فيديو (H.264/H.265) + M4A صوت (AAC). يتم تصفية الخيارات غير المتوافقة تلقائياً
- إذا فشل الدمج (مثلاً صيغة غير مدعومة)، يبقى الملفان منفصلين مع تسجيل رسالة الخطأ التفصيلية (Logcat + Dart log)

### مشغل يوتيوب الراديو — التحسينات (2026-06-12)

- **معالجة الأخطاء**: إضافة `_hasError` + `_retry()` — بعد 10 ثواني بدون Ready أو عند `errorCode != 0` يظهر overlay أحمر مع زر "إعادة المحاولة"
- **Buffering indicator**: أيقونة `CircularProgressIndicator` تظهر أثناء `PlayerState.buffering`
- **استرجاع position**: `initialPosition` parameter جديد في `SharedYoutubePlayer` + `YoutubePlayerWidget` + `AudioVideoSwiper` — يستخدم `PlaybackPositionService.getPositionAsync()` لاستئناف المشاهدة من آخر نقطة
- **جودة حقيقية**: إضافة `_applyQuality()` تستدعي `player.setPlaybackQuality()` عبر WebView JS API (hd1080/hd720/large/medium/default) — تطبق بعد Ready وعند تغيير الإعدادات
- **الملفات المتأثرة**: `shared_youtube_player.dart` + `youtube_player_widget.dart` + `audio_video_swiper.dart`

### إصلاحات الأخطاء الجذرية (2026-06-13)

- **`shared_youtube_player.dart:562`** — طبقة اللمس (`HitTestBehavior.opaque`) كانت فوق طبقة الخطأ، مما يمنع زر "إعادة المحاولة". الحل: `if (!_hasError)` قبل طبقة اللمس.
- **`shared_youtube_player.dart:260`** — `_initTimeout` لا يُعاد تعيينه بعد `_retry()`. الحل: إضافة `_initTimeout = null` قبل `_initController()`.
- **`audio_video_swiper.dart:51`** — سباق توقيت: `_loadInitialPosition()` async، والمشغل يُبنى قبل اكتمال التحميل. الحل: إضافة `_positionLoaded` flag + إرجاء بناء `YoutubePlayerWidget` لحين تحميل الموضع.
- **`audio_video_swiper.dart:118`** — `_saveCurrentPosition()` كانت fire-and-forget. الحل: جعلها `Future<void>` + `await` على الحفظ.
- **`shared_youtube_player.dart:410`** — `_applyQuality()` غير منتظرة في `onChanged`. الحل: إضافة `await`.

### تحسينات تجربة المستخدم (2026-06-15)

- **`shared_youtube_player.dart:13-44`** — `SharedYoutubePlaybackController` كلاس خارجي للتحكم بالمشغل (`play()` / `pause()` / `seekTo()` / `position` getter). يربط نفسه بـ `_attach()`/`_detach()` على التوالي، ويستخدمه `AudioVideoSwiper` لتشغيل/إيقاف الفيديو عند التبديل بين التبويبين.
- **`shared_youtube_player.dart:107`** — حارس التهيئة: إضافة `_controllerReady` flag؛ `build()` يعرض واجهة انتظار (spinner + "جاري تجهيز مشغل يوتيوب...") حتى يكتمل تهيئة `_ytController`. يمنع `LateInitializationError` لو فشل `_loadPreferences()`.
- **`shared_youtube_player.dart:336-353`** — `_retry()` الآن يتحقق من `_controllerReady` قبل مسح المستمعين والتخلص من المتحكم، ويفصل `playbackController` إن وُجد.
- **`shared_youtube_player.dart:547-557`** — `dispose()` يتحقق من `_controllerReady` قبل `removeListener`/`dispose` ويفصل `playbackController`.
- **`audio_video_swiper.dart:400-447`** — `_buildYoutubePositionLoader()` يعرض spinner + "جاري استعادة موضع الفيديو..." + زر "ابدأ من البداية" لحين تحميل الموضع المخزّن. اختيار المستخدم "ابدأ من البداية" يضبط `_skipInitialPosition = true` ليمنع async overload.
- **`audio_video_swiper.dart:56,84`** — إضافة `_skipInitialPosition` flag + التحقق منه في `_loadInitialPosition()` لمنع الكتابة فوق اختيار المستخدم.
- **الملفات المتأثرة**: `shared_youtube_player.dart` + `youtube_player_widget.dart` + `audio_video_swiper.dart`

### إصلاحات مشغل القنوات (2026-06-15)

- **`video_player_screen.dart:104-106`** — إضافة `_hasError`، `_isBuffering`، `_initTimeout` (نفس نمط `SharedYoutubePlayer`).
- **`video_player_screen.dart:374-410`** — تحديث `_listener()`: فحص `errorCode != 0` → تعيين `_hasError`، فحص `PlayerState.buffering`، إضافة مهلة 10 ثوانٍ للتهيئة (`_initTimeout`) تُلغى عند `isReady`.
- **`video_player_screen.dart:212-222`** — إضافة `_retry()`: تلغي `_initTimeout`، تعيد تعيين `_hasError`/`_isBuffering`، تستدعي `_rebuildPlayerWithSettings()` لإعادة إنشاء المتحكم.
- **`video_player_screen.dart:431`** — `dispose()`: إلغاء `_initTimeout` قبل التخلص من المتحكم.
- **`video_player_screen.dart:1300-1362`** — إضافة overlay الخطأ (رمز + "تعذر تشغيل الفيديو" + زر "إعادة المحاولة") ومؤشر buffering (spinner) في `_buildPlayer()`.
- **`video_player_screen.dart:1364-1391`** — حارس `if (!_hasError)` على طبقة اللمس (نفس خطأ الراديو).
- **الملف المتأثر**: `lib/screens/channels/video_player_screen.dart`

### Invidious API — النقاط الرئيسية

- `_instances`: 7 instances (yewtu.be, snopyta, privacydev, إلخ)
- `_findWorkingInstance()`: يختبر `/api/v1/stats` ويخزّن الـ instance الشغالة
- `fetchVideoInfo(videoId)`: يجلب `formatStreams` (مدمجة) + `adaptiveFormats` (فيديو/صوت منفصل)
- `getQualities(url)`: يرجع فقط الـ merged streams (مدمجة = فيديو + صوت معاً) + audio-only
- `getDownloadUrl(url, quality)`: يطابق الجودة المختارة مع الـ stream URL
- **Rate limiting**: لو الـ instance رجع 429/5xx، يعيد تعيينها ويجرب التالية

### تغييرات ملحوظة عن الإصدار القديم

- Cobalt API: `vQuality` من `'720'` ← `'max'` (لم يعد محدوداً بـ 720p)، والآن 3 جودات بالتوازي
- `getQualities()`: يعرض ALL جودات فيديو مع صوت (مدمج أصلي + مدمج بـ ffmpeg من adaptiveFormats)
- `downloadVideo()`: يدعم `audioStreamUrl` (تحميل مزدوج + دمج بـ MediaMuxer الأصلي)
- إزالة `ffmpeg_kit_flutter_min_gpl` ← استبدالها بـ `MediaMuxer` نيتف (لا تبعيات خارجية، 0 مشاكل Build)
- `_download()` يمرر `audioStreamUrl` كـ `audioUrl` للدمج
- تصفية خيارات الدمج: فقط فيديو mp4 (H.264) + صوت m4a (AAC) — توافق مع MediaMuxer
- تحسين تسجيل الأخطاء: Kotlin يرسل رسالة خطأ مفصلة (بالعربية) إلى Dart عند فشل الدمج
- Invidious + Explode: كلاهما يفضل AAC صوت (m4a) للخيارات المدمجة ويتجاهل فيديو webm
- `SharedYoutubePlayer`: معالجة أخطاء + Buffering + استرجاع position + جودة حقيقية عبر WebView JS API
- `_mergeQualities`: تجاهل videoOnly (hasAudio: false) + الاحتفاظ بالخيارات المدمجة (hasAudio: true + audioStreamUrl)
- الصوت يُحفظ كـ `.mp3` مرافق، ثم يُدمج في ملف `.mp4` واحد
- `_fetchManifest`: مهلة 10s بدل 20s، Android client أولاً
- إضافة `InvidiousApi` كطبقة Shared/Core — 7 instances بالتوازي لزيادة الـ formatStreams

---

## 8. اعتبارات / نواقص معروفة

1. ~~**YouTube content لا يُحفظ في الكاش**~~ → ✅ تم الإصلاح: `_refreshLiveYouTube()` و `_fetchYouTubeChannels()` يخزنان الكاتيغوريز المدمجة في الكاش (`youtube_*.json`) بعد كل تعديل. عند بدء التشغيل، يتم تحميل كاش يوتيوب بعد الـ assets مباشرة (`_loadCachedYouTubeCategories()`) ليتجاوز البيانات القديمة.
2. ~~**Hardcoded download path**~~ → ✅ تم الإصلاح (2026-06-12): استبدال المسار الثابت `/storage/emulated/0/Download/تلاوات/فيديوهات` بـ `getExternalStorageDirectory()` في كلا من `youtube_download_service.dart` و `video_download_service.dart`.
3. **CI يحتاج GitHub Actions / GitLab CI** مفعلين (متوفران الآن)
4. **`youtube_channels.json` لازم يكون موجود في كلا الريبو** (موجود فيه 2 قناة نشطة)
5. **زر Live refresh يستهلك network** — كل قناة في الـ manifest = طلب HTTP. مع 5+ قنوات قد يأخذ 5-10 ثوان
6. **GitLab mirror ما يتحدث تلقائياً** (CI permission issue) — التطبيق يستخدم GitHub أولاً فلا يتأثر

### تم الإصلاح مؤخراً
- ~~**2026-06-28 — أقسام التلاوات تظهر خارج كرت الشيخ**~~ → ✅ الصفحة الرئيسية للتلاوات تعرض الآن كرتاً لكل كاتيغوري/شيخ فقط، مع الاسم والوصف وعدد العناصر، والضغط على الكرت يفتح شاشة التفاصيل نفسها التي كانت تُفتح عبر "See all". لم يتغير منطق الجلب أو التشغيل. اختبار `test/recitations_screen_test.dart` يضمن أن عناصر الشيخ لا تظهر في الخارج وأنها تظهر بعد فتح التفاصيل.
- ~~**2026-06-27 — بطاقات المشايخ في التلاوات كبيرة جداً**~~ → ✅ تصغير أبعاد بطاقات `RecItemCard` عبر `RecSizes.imageHeight()` وإضافة `RecSizes.cardWidth()` كمصدر واحد لحساب العرض، مع تقليل مسافات البطاقة وأزرارها وزيادة عدد العناصر المعروضة في الصف من 6 إلى 8. أضيف اختبار في `test/recitations_screen_test.dart` يثبت أن أبعاد البطاقات على شاشة هاتف تبقى مضغوطة.
- ~~**2026-06-27 — قسم التلاوات لا يعرض بيانات GitHub/GitLab**~~ → ✅ `RecitationsScreen` أصبح يبدأ `RecitationCategoriesData.initialize()` عند فتح القسم ويستمع إلى `RecitationCategoriesData.stream` بدلاً من snapshot ثابت من `build()`. بذلك تظهر بيانات الكاش/الأصول ثم GitHub/GitLab فور وصولها. بحث الراديو يقرأ `RecitationCategoriesData.current` وقت الضغط حتى لا يستخدم قائمة قديمة. أضيف اختبار `test/recitations_screen_test.dart` للتأكد أن كاتيغوري جديد قادم عبر الـ stream يظهر في الواجهة.
- ~~**2026-06-27 — نصوص عربية تظهر كحروف مقطعة**~~ → ✅ إصلاح mojibake داخل Dart string literals فقط بدون تغيير التعليقات أو تنسيق الملفات أو منطق الراديو/التلاوات. أضيف اختبار `test/mojibake_text_test.dart` لمنع رجوع نمط `ط§ظ„...`/`â...`/`ًں...` داخل نصوص الواجهة. كما أضيف placeholder فارغ `assets/quran_pages/.gitkeep` حتى يبقى مسار `assets/quran_pages/` المعلن في `pubspec.yaml` صالحاً.
- ~~**2026-06-12 — مسار التحميل الثابت**~~ → ✅ استبدال `/storage/emulated/0/Download/` بـ `getExternalStorageDirectory()` في `youtube_download_service.dart` و `video_download_service.dart`.
- ~~**2026-06-12 — تسريب ذاكرة VideoFeedScreen**~~ → ✅ `dispose()` الآن يوقف ويحفظ موضع كل الفيديوهات (عبر `_pauseAllVideosBeforeExit()`) بدلاً من الفيديو الحالي فقط.
- ~~**2026-06-12 — توحيد مشغل يوتيوب**~~ → ✅ إنشاء `lib/core/video/shared_youtube_player.dart` كمشغل يوتيوب موحد مع تحكمات كاملة (Play/Pause, Seek, Fullscreen, Settings, Progress). مشغل الراديو (`YoutubePlayerWidget`) الآن يستخدمه، مما يمنحه نفس تحكمات مشغل القنوات.
- ~~**2026-06-15 — الفيديوهات الجديدة في أسفل الكاتيغوري**~~ → ✅ تبديل ترتيب `combined` في `_fetchYouTubeChannels` و `_refreshLiveYouTube`: `[...,mergedGroups, ...nonYouTubeItems]` بدلاً من `[...,nonYouTubeItems, ...mergedGroups]`. الآن مجموعات يوتيوب (🎙️/🔴/📱) تظهر أولاً داخل كل كاتيغوري، ثم عناصر MP3 بعدها. الاختبارات: `youtube_refresh_test.dart` تغطي ترتيب `mergeYouTubeItems` و `_mergeGroupSubItems`.
- ~~**2026-06-15 — تصنيف بثوث مباشرة خاطئ**~~ → ✅ إزالة الكلمات العريضة من Dart `_isLive` (`حوارات`, `اتصالات`, `لقاء`, `مكالمات`, `حواري/حوارنا/حواره/حوارها مع`). الآن Dart `_isLive` يطابق Python `_is_live` بالضبط: فقط `بث`/`مباشر`/`لايف`/`live`/`streaming`/`على الهواء`. الكلمات العريضة كانت تُصنِّف فيديوهات مُعدَّة (مثل "حوار مع نصراني") كبث مباشر. الاختبارات: اختباران جديدان يتأكدان أن `حوارات/اتصالات/لقاء` ≠ live و `بث مباشر/لايف/مباشر` = live.
- ~~**2026-06-15 — metadata في JSON للتصنيف**~~ → ✅ إضافة `isLive` و `durationSeconds` في subItems عبر Python CI (`sync_youtube.py`). Dart Model (`RecitationSubItem`) يقرأ هذه الحقول. Dart `classifySubItem()` يصنّف باستخدام `isLive` أولاً ثم fallback للعنوان. هذا يضمن أن التصنيف دقيق حتى لو العنوان غامض. الملفات: `sync_youtube.py` + `recitation_models.dart` + `recitation_categories_data.dart`. الاختبارات: 5 اختبارات جديدة `classifySubItem`.
- ~~**2026-06-15 — مشاكل حرجة في مشغل يوتيوب**~~ → ✅ 6 إصلاحات: (1) حذف debug prints من `video_page_widget.dart` كانت تطبع عند كل rebuild. (2) استبدال busy-wait loop في `video_cache_manager.dart` بـ Completer مع timeout 30s. (3) LRU eviction في `VideoCacheManager` مع `maxCacheSize=5` لمنع memory leak. (4) استبدال `hashCode` غير المستقر بـ djb2 hash في `video_download_service.dart` و `playback_position_service.dart`. (5) استبدال `disposeAll()` بـ `pauseAll()` في `radio_screen.dart` لمنع crash عند الخروج. (6) حذف `_saveToHistory` المكرر من `audio_coordinator.dart`.

---

## 8. اختيارات معمارية (ADR)

| القرار | السبب |
|---|---|
| `jsonDecode` مباشر بدلاً من `compute()` | `compute()` يفشل مع JSON كبير على بعض الأجهزة |
| Cascade دائماً (لا حصري) | الـ remote أحدث من الكاش |
| `_addCategory` يستبدل لا يتجاهل | الـ remote أحدث من المحلي |
| `if (raw.trim().isEmpty) continue;` | ملفات 0-byte موجودة في assets (placeholder) |
| YouTube في 3 ملفات `.live.json`/`.videos.json`/`.shorts.json` بنفس `RecitationCategory` schema | الـ cascade يدمج items[] من الملفات الـ 3 لنفس `id` تلقائياً؛ الـ player يحدد `videoSource=youtube` |
| Cooldown مفصول لـ YouTube | لا يتأثر بمزامنة mp3، والعكس |
| CI يحدّث `index.json` تلقائياً | لا حاجة لتعديل يدوي عند إضافة قناة |
| `audioUrl=videoUrl` في YouTube items | `rec_item_player_screen.dart` يقرأ `audioUrl` أولاً، فيجب أن يكون YouTube URL |
| زر Refresh يجلب RSS مباشر | لا يعتمد على CI؛ حتى لو CI تأخر، الزر يجلب آخر الفيديوهات |
| `parseYouTubeRss` مكشوف بـ `@visibleForTesting` | يتيح unit test دون HTTP mock |
