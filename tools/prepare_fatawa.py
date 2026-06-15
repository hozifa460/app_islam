# tools/prepare_fatawa.py
import json
import re
from sentence_transformers import SentenceTransformer
import PyPDF2  # لقراءة PDF

model = SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')

def extract_fatawa_from_pdf(pdf_path, scholar_name, book_name):
    """استخراج الفتاوى من ملف PDF"""
    fatawa = []

    with open(pdf_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        full_text = ""
        for page in reader.pages:
            full_text += page.extract_text() + "\n"

    # تقسيم النص إلى فتاوى (حسب نمط الكتاب)
    # مثال: فصل بين سؤال وجواب
    patterns = [
        r'سؤال[:\s]+(.*?)\nجواب[:\s]+(.*?)(?=سؤال|$)',
        r'س[:\s]+(.*?)\nج[:\s]+(.*?)(?=س:|$)',
        r'السؤال[:\s]+(.*?)\nالجواب[:\s]+(.*?)(?=السؤال|$)',
    ]

    for pattern in patterns:
        matches = re.findall(pattern, full_text, re.DOTALL)
        if matches:
            for i, (question, answer) in enumerate(matches):
                fatwa = {
                    'id': f'{book_name}_{i+1}',
                    'question': question.strip(),
                    'answer': answer.strip(),
                    'scholar': scholar_name,
                    'book': book_name,
                    'category': classify_fatwa(question),
                    'keywords': extract_keywords(question + ' ' + answer),
                }
                fatawa.append(fatwa)
            break

    return fatawa

def classify_fatwa(text):
    """تصنيف الفتوى تلقائياً"""
    categories = {
        'صلاة': ['صلاة', 'صلى', 'ركعة', 'سجود', 'ركوع', 'قيام', 'تشهد', 'إمام', 'مأموم', 'جماعة', 'أذان', 'إقامة'],
        'زكاة': ['زكاة', 'نصاب', 'صدقة', 'عشر', 'فطر'],
        'صيام': ['صيام', 'صوم', 'رمضان', 'إفطار', 'سحور', 'قضاء'],
        'حج': ['حج', 'عمرة', 'طواف', 'سعي', 'إحرام', 'منى', 'عرفة', 'مزدلفة'],
        'طهارة': ['وضوء', 'غسل', 'تيمم', 'طهارة', 'نجاسة', 'حيض', 'جنابة'],
        'نكاح': ['زواج', 'نكاح', 'مهر', 'طلاق', 'خلع', 'عدة', 'نفقة'],
        'بيوع': ['بيع', 'شراء', 'ربا', 'تجارة', 'قرض', 'دين', 'رهن'],
        'أطعمة': ['أكل', 'شرب', 'طعام', 'لحم', 'ذبح', 'حلال', 'حرام'],
        'عقيدة': ['توحيد', 'شرك', 'إيمان', 'كفر', 'بدعة', 'سنة'],
        'جنائز': ['موت', 'جنازة', 'دفن', 'قبر', 'تعزية', 'غسل الميت'],
        'أذكار': ['دعاء', 'ذكر', 'استغفار', 'تسبيح', 'قرآن', 'تلاوة'],
    }

    text_lower = text.lower()
    scores = {}
    for cat, keywords in categories.items():
        score = sum(1 for kw in keywords if kw in text_lower)
        if score > 0:
            scores[cat] = score

    return max(scores, key=scores.get) if scores else 'عام'

def extract_keywords(text):
    """استخراج كلمات مفتاحية"""
    # كلمات التوقف
    stop_words = {'في', 'من', 'إلى', 'على', 'عن', 'مع', 'هل', 'ما', 'هو', 'هي',
                  'أن', 'إن', 'كان', 'لا', 'لم', 'قد', 'و', 'أو', 'ثم', 'هذا', 'هذه'}

    words = re.findall(r'[\u0600-\u06FF]+', text)
    keywords = [w for w in words if len(w) > 2 and w not in stop_words]

    # أكثر الكلمات تكراراً
    from collections import Counter
    common = Counter(keywords).most_common(10)
    return [word for word, count in common]

def generate_embeddings(fatawa):
    """إنشاء embeddings لجميع الفتاوى"""
    texts = [f"{f['question']} {f['answer'][:200]}" for f in fatawa]
    embeddings = model.encode(texts)

    for i, fatwa in enumerate(fatawa):
        fatwa['embedding'] = embeddings[i].tolist()

    return fatawa

# ═══════════════════════════════════════
# الاستخدام
# ═══════════════════════════════════════
if __name__ == '__main__':
    all_fatawa = []

    # كتاب 1
    fatawa1 = extract_fatawa_from_pdf(
        'books/fatawa_ibn_baz.pdf',
        'ابن باز',
        'مجموع فتاوى ابن باز'
    )
    all_fatawa.extend(fatawa1)

    # كتاب 2
    fatawa2 = extract_fatawa_from_pdf(
        'books/ibn_uthaimine_1_text.pdf',
        'ابن عثيمين',
        'فتاوى نور على الدرب'
    )
    all_fatawa.extend(fatawa2)

    # إنشاء Embeddings
    print(f"إجمالي الفتاوى: {len(all_fatawa)}")
    all_fatawa = generate_embeddings(all_fatawa)

    # حفظ
    with open('fatawa_with_embeddings.json', 'w', encoding='utf-8') as f:
        json.dump({'fatawa': all_fatawa}, f, ensure_ascii=False, indent=2)

    # حفظ نسخة بدون embeddings للتطبيق
    for f in all_fatawa:
        f.pop('embedding', None)

    with open('assets/json/fatawa_main.json', 'w', encoding='utf-8') as f:
        json.dump({'fatawa': all_fatawa}, f, ensure_ascii=False, indent=2)

    print("تم التجهيز بنجاح! ✅")