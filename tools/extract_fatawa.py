import json
import re
import os
from collections import Counter

class FatawaExtractor:
    def __init__(self):
        self.fatawa = []
        self.id_counter = 1

    # ══════════════════════════════════════════════
    # الطريقة الرئيسية: استخراج من PDF
    # ══════════════════════════════════════════════
    def extract_from_pdf(self, pdf_path, scholar, book):
        print(f"\n📚 معالجة: {book}")
        print(f"📁 الملف: {pdf_path}")

        if not os.path.exists(pdf_path):
            print(f"❌ الملف غير موجود: {pdf_path}")
            return []

        # المحاولة 1: pymupdf (الأقوى)
        text = self._read_with_pymupdf(pdf_path)

        # المحاولة 2: pdfplumber
        if not text or len(text) < 1000:
            print("⚠️ pymupdf فشل، جاري تجربة pdfplumber...")
            text = self._read_with_pdfplumber(pdf_path)

        # المحاولة 3: PyPDF2
        if not text or len(text) < 1000:
            print("⚠️ pdfplumber فشل، جاري تجربة PyPDF2...")
            text = self._read_with_pypdf2(pdf_path)

        if not text or len(text) < 1000:
            print("❌ فشل استخراج النص من PDF بجميع الطرق")
            return []

        print(f"📝 حجم النص المستخرج: {len(text)} حرف")

        # حفظ النص في ملف للمراجعة
        debug_path = pdf_path.replace('.pdf', '_debug.txt')
        with open(debug_path, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f"🔍 تم حفظ النص في: {debug_path}")

        return self._parse_text(text, scholar, book)

    # ══════════════════════════════════════════════
    # استخراج من TXT مباشرة
    # ══════════════════════════════════════════════
    def extract_from_txt(self, txt_path, scholar, book):
        print(f"\n📚 معالجة: {book}")
        print(f"📁 الملف: {txt_path}")

        if not os.path.exists(txt_path):
            print(f"❌ الملف غير موجود: {txt_path}")
            return []

        with open(txt_path, 'r', encoding='utf-8') as f:
            text = f.read()

        print(f"📝 حجم النص: {len(text)} حرف")
        return self._parse_text(text, scholar, book)

    # ══════════════════════════════════════════════
    # قراءة PDF بـ pymupdf (الأقوى)
    # ══════════════════════════════════════════════
    def _read_with_pymupdf(self, pdf_path):
        try:
            import fitz
            doc = fitz.open(pdf_path)
            print(f"📖 عدد الصفحات: {len(doc)}")

            full_text = ""
            for i, page in enumerate(doc):
                text = page.get_text("text")
                if text:
                    full_text += text + "\n"
                if (i + 1) % 50 == 0:
                    print(f"  ✅ تمت معالجة {i+1} صفحة...")

            doc.close()
            print(f"  ✅ pymupdf: استخرج {len(full_text)} حرف")
            return full_text

        except ImportError:
            print("  ⚠️ pymupdf غير مثبت. ثبته: pip install pymupdf")
            return None
        except Exception as e:
            print(f"  ❌ خطأ pymupdf: {e}")
            return None

    # ══════════════════════════════════════════════
    # قراءة PDF بـ pdfplumber
    # ══════════════════════════════════════════════
    def _read_with_pdfplumber(self, pdf_path):
        try:
            import pdfplumber
            full_text = ""

            with pdfplumber.open(pdf_path) as pdf:
                print(f"📖 عدد الصفحات: {len(pdf.pages)}")
                for i, page in enumerate(pdf.pages):
                    text = page.extract_text()
                    if text:
                        full_text += text + "\n"
                    if (i + 1) % 50 == 0:
                        print(f"  ✅ تمت معالجة {i+1} صفحة...")

            print(f"  ✅ pdfplumber: استخرج {len(full_text)} حرف")
            return full_text

        except ImportError:
            print("  ⚠️ pdfplumber غير مثبت. ثبته: pip install pdfplumber")
            return None
        except Exception as e:
            print(f"  ❌ خطأ pdfplumber: {e}")
            return None

    # ══════════════════════════════════════════════
    # قراءة PDF بـ PyPDF2
    # ══════════════════════════════════════════════
    def _read_with_pypdf2(self, pdf_path):
        try:
            import PyPDF2
            full_text = ""

            with open(pdf_path, 'rb') as f:
                reader = PyPDF2.PdfReader(f)
                print(f"📖 عدد الصفحات: {len(reader.pages)}")

                for i, page in enumerate(reader.pages):
                    text = page.extract_text()
                    if text:
                        full_text += text + "\n"
                    if (i + 1) % 50 == 0:
                        print(f"  ✅ تمت معالجة {i+1} صفحة...")

            print(f"  ✅ PyPDF2: استخرج {len(full_text)} حرف")
            return full_text

        except ImportError:
            print("  ⚠️ PyPDF2 غير مثبت. ثبته: pip install PyPDF2")
            return None
        except Exception as e:
            print(f"  ❌ خطأ PyPDF2: {e}")
            return None

    # ══════════════════════════════════════════════
    # تحليل النص واستخراج الفتاوى
    # يجرب 4 أنماط مختلفة حتى ينجح واحد
    # ══════════════════════════════════════════════
    def _parse_text(self, text, scholar, book):
        print("\n🔍 جاري تحليل النص واستخراج الفتاوى...")

        # تنظيف النص أولاً
        text = self._clean_raw_text(text)

        # قص الفهارس من آخر الكتاب
        text = self._cut_indexes(text)

        extracted = []

        # النمط 1: (رقم) ... فأجاب ...
        extracted = self._try_pattern_numbered_faajab(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 1 (رقم + فأجاب): {len(extracted)} فتوى")
            return extracted

        # النمط 2: (رقم) ... الجواب: ...
        extracted = self._try_pattern_numbered_jawab(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 2 (رقم + الجواب): {len(extracted)} فتوى")
            return extracted

        # النمط 3: سؤال: ... جواب: ...
        extracted = self._try_pattern_question_answer(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 3 (سؤال/جواب): {len(extracted)} فتوى")
            return extracted

        # النمط 4: س: ... ج: ...
        extracted = self._try_pattern_short(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 4 (س/ج): {len(extracted)} فتوى")
            return extracted

        # النمط 5: تقسيم بكلمة "أجاب" فقط
        extracted = self._try_pattern_ajab_only(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 5 (أجاب فقط): {len(extracted)} فتوى")
            return extracted

        # النمط 6: تقسيم يدوي بالأرقام بين الأقواس
        extracted = self._try_pattern_numbers_only(text, scholar, book)
        if extracted:
            print(f"✅ نجح النمط 6 (أرقام فقط): {len(extracted)} فتوى")
            return extracted

        print("❌ لم ينجح أي نمط في استخراج الفتاوى")
        print("💡 تلميح: افتح ملف _debug.txt وأرسل 20 سطراً من فتوى")
        return []

    # ══════════════════════════════════════════════
    # النمط 1: (رقم) ... فأجاب -رحمه الله تعالى-: ...
    # ══════════════════════════════════════════════
    def _try_pattern_numbered_faajab(self, text, scholar, book):
        extracted = []

        # تقسيم بالأرقام
        parts = re.split(r'\((\d+)\)', text)

        for i in range(1, len(parts) - 1, 2):
            f_id = parts[i]
            content = parts[i + 1]

            # البحث عن أي صيغة من "أجاب"
            if 'جاب' in content:
                sub = re.split(r'(فأجاب|أجاب|فاجاب|اجاب)', content, maxsplit=1)

                if len(sub) >= 3:
                    question = sub[0].strip()
                    answer = sub[2].strip()

                    # تنظيف مقدمة الجواب
                    answer = re.sub(
                        r'^[\s\-]*رحمه\s*الله\s*تعالى[\s\-]*[:\-]*',
                        '', answer
                    ).strip()

                    # تنظيف السؤال
                    question = self._clean_question_text(question)

                    if len(question) > 10 and len(answer) > 30:
                        fatwa = self._create_fatwa(
                            question, answer, scholar, book
                        )
                        fatwa['id'] = f_id
                        extracted.append(fatwa)

        return extracted

    # ══════════════════════════════════════════════
    # النمط 2: (رقم) ... الجواب: ...
    # ══════════════════════════════════════════════
    def _try_pattern_numbered_jawab(self, text, scholar, book):
        extracted = []

        parts = re.split(r'\((\d+)\)', text)

        for i in range(1, len(parts) - 1, 2):
            f_id = parts[i]
            content = parts[i + 1]

            if 'الجواب' in content:
                sub = re.split(r'الجواب\s*[:\-]', content, maxsplit=1)

                if len(sub) >= 2:
                    question = sub[0].strip()
                    answer = sub[1].strip()

                    question = self._clean_question_text(question)

                    if len(question) > 10 and len(answer) > 30:
                        fatwa = self._create_fatwa(
                            question, answer, scholar, book
                        )
                        fatwa['id'] = f_id
                        extracted.append(fatwa)

        return extracted

    # ══════════════════════════════════════════════
    # النمط 3: سؤال: ... جواب: ...
    # ══════════════════════════════════════════════
    def _try_pattern_question_answer(self, text, scholar, book):
        extracted = []

        pattern = re.compile(
            r'(?:سؤال|السؤال)\s*[:\-]\s*(.*?)\s*(?:جواب|الجواب)\s*[:\-]\s*(.*?)(?=(?:سؤال|السؤال)\s*[:\-]|$)',
            re.DOTALL
        )

        for match in pattern.finditer(text):
            question = match.group(1).strip()
            answer = match.group(2).strip()

            question = self._clean_question_text(question)

            if len(question) > 10 and len(answer) > 30:
                extracted.append(
                    self._create_fatwa(question, answer, scholar, book)
                )

        return extracted

    # ══════════════════════════════════════════════
    # النمط 4: س: ... ج: ...
    # ══════════════════════════════════════════════
    def _try_pattern_short(self, text, scholar, book):
        extracted = []

        pattern = re.compile(
            r'س\s*[:\-]\s*(.*?)\s*ج\s*[:\-]\s*(.*?)(?=س\s*[:\-]|$)',
            re.DOTALL
        )

        for match in pattern.finditer(text):
            question = match.group(1).strip()
            answer = match.group(2).strip()

            question = self._clean_question_text(question)

            if len(question) > 10 and len(answer) > 30:
                extracted.append(
                    self._create_fatwa(question, answer, scholar, book)
                )

        return extracted

    # ══════════════════════════════════════════════
    # النمط 5: تقسيم بكلمة "أجاب" فقط
    # ══════════════════════════════════════════════
    def _try_pattern_ajab_only(self, text, scholar, book):
        extracted = []

        parts = re.split(r'(فأجاب|أجاب|فاجاب|اجاب)', text)

        for i in range(0, len(parts) - 2, 2):
            question_part = parts[i].strip()
            answer_part = parts[i + 2].strip() if (i + 2) < len(parts) else ""

            # تنظيف
            answer_part = re.sub(
                r'^[\s\-]*رحمه\s*الله\s*تعالى[\s\-]*[:\-]*',
                '', answer_part
            ).strip()

            # السؤال = آخر 500 حرف قبل كلمة أجاب
            if len(question_part) > 500:
                question_part = question_part[-500:]

            # ابحث عن بداية السؤال
            q_markers = [
                'يقول السائل', 'تقول السائلة', 'سئل', 'وسئل',
                'هذا سؤال', 'يسأل', 'تسأل'
            ]
            for marker in q_markers:
                if marker in question_part:
                    question_part = question_part.split(marker)[-1]
                    break

            question_part = self._clean_question_text(question_part)

            # قطع الجواب عند بداية السؤال القادم
            end_markers = [
                'يقول السائل', 'تقول السائلة', 'سئل فضيلة',
                'هذا سؤال'
            ]
            for marker in end_markers:
                if marker in answer_part:
                    answer_part = answer_part.split(marker)[0]

            if len(question_part) > 10 and len(answer_part) > 30:
                extracted.append(
                    self._create_fatwa(
                        question_part, answer_part, scholar, book
                    )
                )

        return extracted

    # ══════════════════════════════════════════════
    # النمط 6: تقسيم بالأرقام فقط
    # ══════════════════════════════════════════════
    def _try_pattern_numbers_only(self, text, scholar, book):
        extracted = []

        parts = re.split(r'\((\d+)\)', text)

        for i in range(1, len(parts) - 1, 2):
            f_id = parts[i]
            content = parts[i + 1].strip()

            if len(content) > 100:
                # أول جملة = السؤال، الباقي = الجواب
                sentences = re.split(r'[؟\?]', content, maxsplit=1)

                if len(sentences) >= 2:
                    question = sentences[0].strip() + '؟'
                    answer = sentences[1].strip()

                    question = self._clean_question_text(question)

                    if len(question) > 10 and len(answer) > 30:
                        fatwa = self._create_fatwa(
                            question, answer, scholar, book
                        )
                        fatwa['id'] = f_id
                        extracted.append(fatwa)

        return extracted

    # ══════════════════════════════════════════════
    # إنشاء كائن الفتوى
    # ══════════════════════════════════════════════
    def _create_fatwa(self, question, answer, scholar, book):
        fatwa = {
            'id': str(self.id_counter),
            'question': question[:500],
            'answer': answer,
            'scholar': scholar,
            'book': book,
            'category': self._classify(question + ' ' + answer),
            'keywords': self._extract_keywords(question + ' ' + answer),
            'source': f"{scholar} - {book}",
        }
        self.id_counter += 1
        return fatwa

    # ══════════════════════════════════════════════
    # تنظيف النص الخام
    # ══════════════════════════════════════════════
    def _clean_raw_text(self, text):
        # حذف التشكيل
        text = re.sub(r'[ًٌٍَُِّْٰ]', '', text)
        # تبسيط المسافات
        text = re.sub(r'\s+', ' ', text)
        return text

    # ══════════════════════════════════════════════
    # تنظيف نص السؤال
    # ══════════════════════════════════════════════
    def _clean_question_text(self, question):
        # إزالة رموز غريبة
        question = re.sub(r'^[\s\d\-\|\(\)\[\]ذا!م]+', '', question)
        # إزالة "يقول السائل" و "تقول السائلة" من البداية
        question = re.sub(
            r'^(يقول السائل|تقول السائلة|سئل فضيلة الشيخ|فضيلة الشيخ|هذا سؤال بعث به).*?[:\-]',
            '', question
        ).strip()
        # تنظيف المسافات
        question = re.sub(r'\s+', ' ', question).strip()
        return question

    # ══════════════════════════════════════════════
    # قص الفهارس من آخر الكتاب
    # ══════════════════════════════════════════════
    def _cut_indexes(self, text):
        markers = [
            "فهرس الايات", "فهرس الاحاديث", "فهرس الموضوعات",
            "فهرس الفوائد", "الفهارس", "نبذة مختصرة",
        ]
        for marker in markers:
            if marker in text:
                text = text.split(marker)[0]
                print(f"  ✂️ تم قطع الفهرس عند: {marker}")
                break
        return text

    # ══════════════════════════════════════════════
    # تصنيف الفتوى
    # ══════════════════════════════════════════════
    def _classify(self, text):
        categories = {
            'صلاة': ['صلاه', 'صلى', 'يصلي', 'ركعه', 'سجود', 'ركوع',
                     'اذان', 'اقامه', 'امام', 'مأموم', 'جماعه',
                     'جمعه', 'تراويح', 'وتر', 'سهو', 'قبله'],
            'زكاة': ['زكاه', 'نصاب', 'صدقه', 'عشر', 'فطر'],
            'صيام': ['صيام', 'صوم', 'رمضان', 'افطار', 'سحور', 'صائم'],
            'حج': ['حج', 'عمره', 'طواف', 'سعي', 'احرام', 'مكه', 'عرفه'],
            'طهارة': ['وضوء', 'غسل', 'تيمم', 'طهاره', 'نجاسه', 'حيض'],
            'نكاح': ['زواج', 'نكاح', 'مهر', 'طلاق', 'خلع', 'عده', 'نفقه'],
            'بيوع': ['بيع', 'شراء', 'ربا', 'تجاره', 'قرض', 'دين'],
            'عقيدة': ['توحيد', 'شرك', 'ايمان', 'كفر', 'بدعه', 'سنه',
                      'قضاء', 'قدر', 'جنه', 'نار'],
            'جنائز': ['موت', 'جنازه', 'دفن', 'قبر', 'تعزيه', 'كفن'],
            'أذكار': ['دعاء', 'ذكر', 'استغفار', 'تسبيح', 'قرآن', 'تلاوه'],
        }

        scores = {}
        for cat, keywords in categories.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > 0:
                scores[cat] = score

        return max(scores, key=scores.get) if scores else 'عام'

    # ══════════════════════════════════════════════
    # استخراج كلمات مفتاحية
    # ══════════════════════════════════════════════
    def _extract_keywords(self, text):
        stop_words = {
            'في', 'من', 'الى', 'على', 'عن', 'مع', 'هل', 'ما',
            'هو', 'هي', 'ان', 'كان', 'لا', 'لم', 'قد', 'او',
            'ثم', 'هذا', 'هذه', 'ذلك', 'التي', 'الذي',
            'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم',
            'رحمه', 'تعالى', 'ااا', 'البقره',
        }

        words = re.findall(r'[\u0600-\u06FF]{3,}', text)
        filtered = [w for w in words if w not in stop_words]

        common = Counter(filtered).most_common(8)
        return [word for word, _ in common]

    # ══════════════════════════════════════════════
    # إضافة فتاوى
    # ══════════════════════════════════════════════
    def add_fatawa(self, fatawa):
        self.fatawa.extend(fatawa)

    # ══════════════════════════════════════════════
    # حفظ في JSON
    # ══════════════════════════════════════════════
    def save_to_json(self, output_path):
        os.makedirs(os.path.dirname(output_path) or '.', exist_ok=True)

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(
                {'fatawa': self.fatawa, 'total': len(self.fatawa)},
                f, ensure_ascii=False, indent=2
            )
        print(f"\n💾 تم الحفظ: {output_path} ({len(self.fatawa)} فتوى)")


# ══════════════════════════════════════════════
# التشغيل الرئيسي
# ══════════════════════════════════════════════
def main():
    extractor = FatawaExtractor()

    # قائمة الكتب (عدلها حسب كتبك)
    books = [
        {
            'path': 'books/ibn_uthaymine.txt',
            'scholar': 'ابن عثيمين',
            'book': 'فتاوى منار الإسلام',
            'type': 'txt'
        },
    ]

    for book_config in books:
        path = book_config['path']

        if book_config['type'] == 'pdf':
            fatawa = extractor.extract_from_pdf(
                path, book_config['scholar'], book_config['book']
            )
        elif book_config['type'] == 'txt':
            fatawa = extractor.extract_from_txt(
                path, book_config['scholar'], book_config['book']
            )
        else:
            continue

        extractor.add_fatawa(fatawa)

    # حفظ النتيجة
    extractor.save_to_json('output/fatawa_raw.json')

    # إنشاء نسخة للتطبيق
    create_app_version('output/fatawa_raw.json', 'assets/json/fatawa_main.json')

    # طباعة إحصائيات
    print("\n" + "=" * 50)
    print(f"📊 الإحصائيات النهائية:")
    print(f"   إجمالي الفتاوى: {len(extractor.fatawa)}")

    if extractor.fatawa:
        cats = Counter(f['category'] for f in extractor.fatawa)
        print(f"   التصنيفات:")
        for cat, count in cats.most_common():
            print(f"     {cat}: {count}")

        print(f"\n🔍 مثال على أول فتوى:")
        first = extractor.fatawa[0]
        print(f"   السؤال: {first['question'][:100]}...")
        print(f"   الجواب: {first['answer'][:100]}...")


def create_app_version(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"❌ الملف غير موجود: {input_path}")
        return

    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fatawa = data['fatawa']

    # إزالة المكرر
    seen = set()
    unique = []
    for f in fatawa:
        key = f['question'][:50]
        if key not in seen:
            seen.add(key)
            unique.append(f)

    print(f"🗑️ تم حذف {len(fatawa) - len(unique)} مكرر")

    # ترقيم جديد
    for i, f in enumerate(unique):
        f['id'] = str(i + 1)

    os.makedirs(os.path.dirname(output_path) or '.', exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(
            {'fatawa': unique, 'total': len(unique)},
            f, ensure_ascii=False, indent=2
        )

    print(f"✅ نسخة التطبيق: {output_path} ({len(unique)} فتوى)")


if __name__ == '__main__':
    main()