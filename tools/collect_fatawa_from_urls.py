import os
import re
import json
import time
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept-Language": "ar,en;q=0.9",
    "Accept": "text/html",
}

OUTPUT_JSON = "assets/json/fatawa_main.json"

# كم فتوى تريد جمعها من كل موقع (غيّر هذا الرقم حسب رغبتك)
MAX_PER_SITE = 2000


class FatwaCollector:
    def __init__(self):
        self.fatawa = []
        self.seen_urls = set()
        self.id_counter = 1

        # إحصائيات
        self.stats = {
            "tried": 0,
            "success": 0,
            "failed": 0,
            "skipped": 0,
            "duplicate": 0,
        }

        # تحميل الفتاوى القديمة إن وُجدت
        self._load_existing()

    # ══════════════════════════════════════
    # تحميل الفتاوى القديمة لعدم التكرار
    # ══════════════════════════════════════
    def _load_existing(self):
        if os.path.exists(OUTPUT_JSON):
            try:
                with open(OUTPUT_JSON, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    existing = data.get("fatawa", [])
                    self.fatawa = existing
                    self.id_counter = len(existing) + 1

                    # تسجيل الروابط القديمة
                    for fatwa in existing:
                        url = fatwa.get("url", "")
                        if url:
                            self.seen_urls.add(url)

                    print(f"📂 تم تحميل {len(existing)} فتوى سابقة")
            except Exception as e:
                print(f"⚠️ خطأ في تحميل الملف القديم: {e}")

    # ══════════════════════════════════════
    # تحميل صفحة
    # ══════════════════════════════════════
    def fetch(self, url, timeout=15):
        try:
            r = requests.get(url, headers=HEADERS, timeout=timeout, allow_redirects=True)
            if r.status_code == 200 and len(r.text) > 500:
                return r.text
            return None
        except Exception:
            return None

    # ══════════════════════════════════════
    # تنظيف النص
    # ══════════════════════════════════════
    def clean(self, text):
        if not text:
            return ""
        text = re.sub(r'\s+', ' ', text)
        text = text.replace('\xa0', ' ')
        return text.strip()

    # ══════════════════════════════════════
    # استخراج فتوى من ابن باز
    # ══════════════════════════════════════
    def parse_binbaz(self, html, url):
        soup = BeautifulSoup(html, "html.parser")

        title = ""
        h1 = soup.find("h1")
        if h1:
            title = self.clean(h1.get_text(" ", strip=True))
        if not title:
            t = soup.find("title")
            if t:
                title = self.clean(t.get_text())
                title = title.replace(" - موقع الشيخ ابن باز", "").strip()

        if len(title) < 5:
            return None

        question = title
        answer = ""

        # استخراج المحتوى
        for selector in [
            "div.article-body", "div.fatwa-content", "div.entry-content",
            "div.post-content", "article", "div.content", "main",
        ]:
            el = soup.select_one(selector)
            if el:
                text = self.clean(el.get_text(" ", strip=True))
                if len(text) > 100:
                    answer = text
                    break

        if not answer:
            paras = []
            for p in soup.find_all("p"):
                text = self.clean(p.get_text(" ", strip=True))
                if len(text) > 30:
                    paras.append(text)
            answer = "\n\n".join(paras[:20])

        # فصل السؤال عن الجواب
        question, answer = self._split_qa(question, answer)

        if len(question) < 5 or len(answer) < 50:
            return None

        # تقليم الجواب الطويل
        if len(answer) > 3000:
            answer = answer[:3000] + "..."

        return self._make_fatwa(question, answer, "الشيخ ابن باز", "فتاوى ابن باز", url)

    # ══════════════════════════════════════
    # استخراج فتوى من إسلام سؤال وجواب
    # ══════════════════════════════════════
    def parse_islamqa(self, html, url):
        soup = BeautifulSoup(html, "html.parser")

        title = ""
        h1 = soup.find("h1")
        if h1:
            title = self.clean(h1.get_text(" ", strip=True))
        if not title:
            t = soup.find("title")
            if t:
                title = self.clean(t.get_text())
                title = title.replace(" - الإسلام سؤال وجواب", "").strip()

        if len(title) < 5:
            return None

        question = title
        answer = ""

        for selector in [
            "div.post-content", "div.answer-content", "div.entry-content",
            "div.fatwa-answer", "article", "main",
        ]:
            el = soup.select_one(selector)
            if el:
                text = self.clean(el.get_text(" ", strip=True))
                if len(text) > 100:
                    answer = text
                    break

        if not answer:
            paras = []
            for p in soup.find_all("p"):
                text = self.clean(p.get_text(" ", strip=True))
                if len(text) > 30:
                    paras.append(text)
            answer = "\n\n".join(paras[:20])

        question, answer = self._split_qa(question, answer)

        if len(question) < 5 or len(answer) < 50:
            return None

        if len(answer) > 3000:
            answer = answer[:3000] + "..."

        return self._make_fatwa(question, answer, "إسلام سؤال وجواب", "إسلام سؤال وجواب", url)

    # ══════════════════════════════════════
    # استخراج فتوى من إسلام ويب
    # ══════════════════════════════════════
    def parse_islamweb(self, html, url):
        soup = BeautifulSoup(html, "html.parser")

        title = ""
        h1 = soup.find("h1")
        if h1:
            title = self.clean(h1.get_text(" ", strip=True))
        if not title:
            t = soup.find("title")
            if t:
                title = self.clean(t.get_text())
                title = title.replace(" - إسلام ويب - مركز الفتوى", "").strip()

        if len(title) < 5:
            return None

        question = title
        answer = ""

        for selector in [
            "div.fatwa-body", "div.article-body", "div.content-body",
            "div.entry-content", "article", "div.content",
        ]:
            el = soup.select_one(selector)
            if el:
                text = self.clean(el.get_text(" ", strip=True))
                if len(text) > 100:
                    answer = text
                    break

        if not answer:
            paras = []
            for p in soup.find_all("p"):
                text = self.clean(p.get_text(" ", strip=True))
                if len(text) > 30:
                    paras.append(text)
            answer = "\n\n".join(paras[:20])

        question, answer = self._split_qa(question, answer)

        if len(question) < 5 or len(answer) < 50:
            return None

        if len(answer) > 3000:
            answer = answer[:3000] + "..."

        return self._make_fatwa(question, answer, "إسلام ويب", "إسلام ويب", url)

    # ══════════════════════════════════════
    # فصل السؤال عن الجواب
    # ══════════════════════════════════════
    def _split_qa(self, title, content):
        patterns = [
            r'السؤال[:\s]*(.*?)(?:الجواب|الإجابة|الإجاب(?:ة|ــة))[:\s]*(.*)',
            r'سؤال[:\s]*(.*?)(?:جواب|إجابة)[:\s]*(.*)',
            r'نص السؤال[:\s]*(.*?)نص الجواب[:\s]*(.*)',
            r'الحمد لله[.\s]*(.*)',
        ]

        for pattern in patterns:
            m = re.search(pattern, content, re.DOTALL)
            if m:
                if len(m.groups()) == 2:
                    q = self.clean(m.group(1))
                    a = self.clean(m.group(2))
                    if len(q) > 5 and len(a) > 30:
                        return q, a
                elif len(m.groups()) == 1:
                    a = self.clean(m.group(1))
                    if len(a) > 30:
                        return title, a

        return title, content

    # ══════════════════════════════════════
    # إنشاء كائن الفتوى
    # ══════════════════════════════════════
    def _make_fatwa(self, question, answer, scholar, book, url):
        fatwa = {
            "id": str(self.id_counter),
            "question": question,
            "answer": answer,
            "scholar": scholar,
            "book": book,
            "category": self._classify(question + " " + answer),
            "keywords": self._keywords(question + " " + answer),
            "source": book,
            "url": url,
        }
        self.id_counter += 1
        return fatwa

    # ══════════════════════════════════════
    # تصنيف
    # ══════════════════════════════════════
    def _classify(self, text):
        text_normalized = text \
            .replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا') \
            .replace('ة', 'ه').replace('ى', 'ي')

        cats = {
            'صلاة':    [
              'صلاه', 'يصلي', 'ركعه', 'ركعات', 'سجود', 'ركوع', 'امام',
              'جماعه', 'مسجد', 'اذان', 'اقامه', 'قبله', 'فجر', 'ظهر',
              'عصر', 'مغرب', 'عشاء', 'جمعه', 'تراويح', 'وتر', 'سهو',
              'صلاه الجنازه', 'صلاه العيد', 'المصلي', 'الصلوات',
            ],
            'طهارة': [
              'وضوء', 'يتوضا', 'غسل', 'تيمم', 'طهاره', 'نجاسه',
              'حيض', 'جنابه', 'استنجاء', 'مسح', 'خف', 'جورب',
              'دم', 'البول', 'الغائط', 'المذي', 'الودي',
            ],
           'صيام': [
              'صيام', 'صوم', 'رمضان', 'افطار', 'سحور', 'صائم',
              'كفاره', 'فديه', 'اعتكاف', 'يصوم', 'الصوم', 'مفطر',
              'ليله القدر', 'تراويح رمضان',
           ],
           'زكاة': [
              'زكاه', 'نصاب', 'صدقه', 'عشر', 'زكاه الفطر',
              'زكاه المال', 'زكاه الذهب', 'زكاه الفضه',
              'المستحقون', 'الفقراء والمساكين',
           ],
            'حج': [
              'حج', 'عمره', 'طواف', 'سعي', 'احرام', 'مكه',
              'عرفه', 'منى', 'مزدلفه', 'رمي', 'جمره', 'تلبيه',
              'الحاج', 'المعتمر', 'المحرم', 'البيت الحرام',
            ],
            'نكاح': [
              'زواج', 'نكاح', 'طلاق', 'خلع', 'عده', 'مهر',
              'نفقه', 'خطبه', 'ولي', 'شاهد', 'عقد الزواج',
              'الزوج', 'الزوجه', 'الطلاق', 'الرجعه', 'المهر',
            ],
            'بيوع': [
              'بيع', 'شراء', 'ربا', 'تجاره', 'قرض', 'دين',
              'اجاره', 'مضاربه', 'شركه', 'سلم', 'خيار',
              'الفائده', 'البنك', 'الديون', 'العقود',
            ],
            'عقيدة': [
              'توحيد', 'شرك', 'ايمان', 'كفر', 'بدعه', 'قدر',
               'سنه', 'اهل السنه', 'العقيده', 'الصفات', 'الاسماء',
               'الجنه', 'النار', 'اليوم الاخر', 'القبر',
           ],

            'جنائز': [
              'ميت', 'موت', 'جنازه', 'دفن', 'قبر', 'تعزيه',
              'كفن', 'غسل الميت', 'صلاه الجنازه', 'الوفاه',
            ],
            'أذكار': [
               'دعاء', 'ذكر', 'استغفار', 'تسبيح', 'قران',
               'تلاوه', 'حفظ القران', 'الاذكار', 'الادعيه',
            ],
            'أطعمة': [
              'حلال', 'حرام', 'اكل', 'شرب', 'ذبح', 'لحم',
              'خمر', 'مسكر', 'الطعام', 'الذبيحه', 'التدخين',
            ],
        }

        scores = {}
        for cat, words in cats.items():
           score = sum(1 for w in words if w in text_normalized)
           if score > 0:
             scores[cat] = score

        return max(scores, key=scores.get) if scores else 'عام'

    # ══════════════════════════════════════
    # كلمات مفتاحية
    # ══════════════════════════════════════
    def _keywords(self, text):
        stop = {
            'في', 'من', 'على', 'عن', 'إلى', 'هل', 'ما', 'هو', 'هي',
            'أن', 'إن', 'كان', 'لا', 'لم', 'قد', 'و', 'أو', 'ثم',
            'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم', 'تعالى',
            'عنه', 'رضي', 'بن', 'عبد', 'ابن', 'أبو', 'قال', 'يقول',
        }
        words = re.findall(r'[\u0600-\u06FF]{3,}', text)
        words = [w for w in words if w not in stop]
        freq = {}
        for w in words:
            freq[w] = freq.get(w, 0) + 1
        return [w for w, _ in sorted(freq.items(), key=lambda x: x[1], reverse=True)[:8]]

    # ══════════════════════════════════════
    # الجمع الرئيسي من ملف الروابط
    # ══════════════════════════════════════
    def collect(self):
        urls_file = "tools/urls_manual.txt"

        if not os.path.exists(urls_file):
            print(f"❌ الملف غير موجود: {urls_file}")
            print("شغّل أولاً: python tools/generate_urls.py")
            return

        with open(urls_file, "r", encoding="utf-8") as f:
            all_urls = [
                line.strip() for line in f
                if line.strip() and not line.startswith("#")
            ]

        print(f"\n📋 إجمالي الروابط في الملف: {len(all_urls)}")
        print(f"📂 فتاوى سابقة محملة: {len(self.fatawa)}")
        print(f"🎯 الحد الأقصى لكل موقع: {MAX_PER_SITE}")

        # تقسيم حسب الموقع
        binbaz_urls = [u for u in all_urls if "binbaz.org.sa" in u]
        islamqa_urls = [u for u in all_urls if "islamqa.info" in u]
        islamweb_urls = [u for u in all_urls if "islamweb.net" in u]
        other_urls = [u for u in all_urls if not any(
            x in u for x in ["binbaz.org.sa", "islamqa.info", "islamweb.net"]
        )]

        print(f"\n📊 التوزيع:")
        print(f"   ابن باز: {len(binbaz_urls)}")
        print(f"   إسلام سؤال وجواب: {len(islamqa_urls)}")
        print(f"   إسلام ويب: {len(islamweb_urls)}")
        print(f"   أخرى: {len(other_urls)}")

        # جمع من كل موقع
        print("\n" + "=" * 50)
        print("1️⃣ جمع من ابن باز")
        print("=" * 50)
        self._collect_from_list(binbaz_urls, "binbaz", MAX_PER_SITE)

        print("\n" + "=" * 50)
        print("2️⃣ جمع من إسلام سؤال وجواب")
        print("=" * 50)
        self._collect_from_list(islamqa_urls, "islamqa", MAX_PER_SITE)

        print("\n" + "=" * 50)
        print("3️⃣ جمع من إسلام ويب")
        print("=" * 50)
        self._collect_from_list(islamweb_urls, "islamweb", MAX_PER_SITE)

    # ══════════════════════════════════════
    # جمع من قائمة روابط
    # ══════════════════════════════════════
    def _collect_from_list(self, urls, site_type, limit):
        count = 0
        consecutive_fails = 0

        for url in urls:
            if count >= limit:
                print(f"\n🎯 وصل الحد الأقصى: {limit}")
                break

            # إذا فشل 20 مرة متتالية توقف
            if consecutive_fails >= 20:
                print(f"\n⚠️ {consecutive_fails} فشل متتالي، تخطي هذا الموقع")
                break

            if url in self.seen_urls:
                self.stats["skipped"] += 1
                continue

            self.seen_urls.add(url)
            self.stats["tried"] += 1

            html = self.fetch(url)

            if not html:
                consecutive_fails += 1
                continue

            consecutive_fails = 0  # إعادة العداد

            # اختيار المحلل المناسب
            fatwa = None
            if site_type == "binbaz":
                fatwa = self.parse_binbaz(html, url)
            elif site_type == "islamqa":
                fatwa = self.parse_islamqa(html, url)
            elif site_type == "islamweb":
                fatwa = self.parse_islamweb(html, url)

            if fatwa:
                self.fatawa.append(fatwa)
                count += 1
                self.stats["success"] += 1

                if count % 10 == 0:
                    print(f"   ✅ [{count}] {fatwa['question'][:60]}")

                # حفظ مؤقت كل 50 فتوى
                if count % 50 == 0:
                    self.save(silent=True)
                    print(f"   💾 حفظ مؤقت ({len(self.fatawa)} فتوى)")
            else:
                self.stats["failed"] += 1

            # انتظار بين الطلبات
            time.sleep(0.8)

        print(f"\n✅ تم جمع {count} فتوى جديدة")

    # ══════════════════════════════════════
    # حفظ
    # ══════════════════════════════════════
    def save(self, silent=False):
        os.makedirs(os.path.dirname(OUTPUT_JSON), exist_ok=True)

        # إزالة المكرر
        unique = []
        seen = set()
        for f in self.fatawa:
            key = f["question"][:150] + "|" + f.get("url", "")
            if key not in seen and len(f["question"]) > 5:
                seen.add(key)
                unique.append(f)

        removed = len(self.fatawa) - len(unique)

        # إعادة الترقيم
        for i, f in enumerate(unique, start=1):
            f["id"] = str(i)

        with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
            json.dump({"fatawa": unique, "total": len(unique)}, f, ensure_ascii=False, indent=2)

        if not silent:
            print(f"\n💾 تم الحفظ: {OUTPUT_JSON}")
            print(f"📊 الإجمالي: {len(unique)} فتوى")
            print(f"🗑️ مكرر محذوف: {removed}")

    # ══════════════════════════════════════
    # طباعة الإحصائيات
    # ══════════════════════════════════════
    def print_stats(self):
        print("\n" + "=" * 50)
        print("📊 الإحصائيات النهائية")
        print("=" * 50)
        print(f"   🔗 روابط تمت تجربتها: {self.stats['tried']}")
        print(f"   ✅ فتاوى مستخرجة: {self.stats['success']}")
        print(f"   ❌ صفحات فاشلة: {self.stats['failed']}")
        print(f"   ⏭️ روابط تم تخطيها: {self.stats['skipped']}")
        print(f"   📚 إجمالي في القاعدة: {len(self.fatawa)}")

        # توزيع حسب المصدر
        sources = {}
        for f in self.fatawa:
            src = f.get("book", "غير معروف")
            sources[src] = sources.get(src, 0) + 1

        print(f"\n   📖 التوزيع حسب المصدر:")
        for src, count in sorted(sources.items(), key=lambda x: x[1], reverse=True):
            print(f"      {src}: {count}")

        # توزيع حسب التصنيف
        cats = {}
        for f in self.fatawa:
            cat = f.get("category", "عام")
            cats[cat] = cats.get(cat, 0) + 1

        print(f"\n   📂 التوزيع حسب التصنيف:")
        for cat, count in sorted(cats.items(), key=lambda x: x[1], reverse=True):
            print(f"      {cat}: {count}")


def main():
    collector = FatwaCollector()
    collector.collect()
    collector.save()
    collector.print_stats()

    print("\n🎉 انتهى!")
    print("📌 شغّل الآن: flutter run")


if __name__ == "__main__":
    main()