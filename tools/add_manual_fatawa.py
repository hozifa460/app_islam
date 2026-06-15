import json
import os

OUTPUT_JSON = "assets/json/fatawa_main.json"

# ══════════════════════════════════════
# أضف فتاوى يدوياً هنا
# انسخها من المواقع مباشرة
# ══════════════════════════════════════
MANUAL_FATAWA = [
    {
        "question": "ما حكم الصلاة جالساً من غير عذر؟",
        "answer": "لا يجوز للمسلم أن يصلي الفريضة جالساً وهو قادر على القيام، لأن القيام ركن من أركان الصلاة. قال الله تعالى: (وَقُومُوا لِلَّهِ قَانِتِينَ). أما من كان عاجزاً عن القيام بسبب المرض أو الكبر أو غيره فيجوز له الصلاة جالساً، لقوله صلى الله عليه وسلم لعمران بن حصين: صلِّ قائماً، فإن لم تستطع فقاعداً، فإن لم تستطع فعلى جنب.",
        "scholar": "ابن باز",
        "book": "فتاوى ابن باز",
        "category": "صلاة",
        "keywords": ["صلاة", "جالس", "قيام", "عذر", "مريض"]
    },
    {
        "question": "ما حكم قراءة القرآن الكريم بدون طهارة؟",
        "answer": "اختلف العلماء في هذه المسألة، والراجح أنه يجوز قراءة القرآن بدون طهارة للمحدث حدثاً أصغر، لعدم الدليل الصريح على منعه. أما الجنب فلا يقرأ القرآن حتى يغتسل عند جمهور العلماء.",
        "scholar": "ابن عثيمين",
        "book": "فتاوى ابن عثيمين",
        "category": "طهارة",
        "keywords": ["قرآن", "طهارة", "وضوء", "جنب", "قراءة"]
    },
    {
        "question": "هل يجوز الإفطار في رمضان بسبب السفر؟",
        "answer": "نعم، يجوز للمسافر أن يفطر في رمضان، وعليه قضاء ما أفطره، قال الله تعالى: (فَمَن كَانَ مِنكُم مَّرِيضًا أَوْ عَلَىٰ سَفَرٍ فَعِدَّةٌ مِّنْ أَيَّامٍ أُخَرَ). والأفضل للمسافر أن يأخذ بالرخصة إذا كان السفر شاقاً.",
        "scholar": "ابن باز",
        "book": "فتاوى ابن باز",
        "category": "صيام",
        "keywords": ["صيام", "سفر", "إفطار", "رمضان", "قضاء"]
    },
    {
        "question": "ما هو نصاب زكاة الذهب والفضة؟",
        "answer": "نصاب الذهب عشرون مثقالاً وهو ما يعادل 85 غراماً من الذهب. ونصاب الفضة مائتا درهم وهو ما يعادل 595 غراماً من الفضة. ومن بلغ ماله النصاب وحال عليه الحول وجبت فيه الزكاة وهي ربع العشر أي 2.5%.",
        "scholar": "ابن باز",
        "book": "فتاوى الزكاة",
        "category": "زكاة",
        "keywords": ["زكاة", "نصاب", "ذهب", "فضة", "ربع العشر"]
    },
    {
        "question": "ما حكم صلاة الجماعة في المسجد؟",
        "answer": "صلاة الجماعة في المسجد واجبة على الرجال القادرين، وهو قول جمهور العلماء، والدليل على ذلك قوله صلى الله عليه وسلم: (لقد هممت أن آمر بالصلاة فتقام، ثم أخالف إلى رجال لا يشهدون الصلاة فأحرق عليهم بيوتهم).",
        "scholar": "ابن عثيمين",
        "book": "الشرح الممتع",
        "category": "صلاة",
        "keywords": ["صلاة", "جماعة", "مسجد", "واجب", "رجال"]
    },
]


def add_manual_fatawa():
    # تحميل الموجود
    existing = []
    if os.path.exists(OUTPUT_JSON):
        with open(OUTPUT_JSON, "r", encoding="utf-8") as f:
            data = json.load(f)
            existing = data.get("fatawa", [])

    print(f"📂 فتاوى سابقة: {len(existing)}")

    # إضافة الجديد
    existing_questions = {f["question"][:80] for f in existing}
    added = 0

    for i, fatwa in enumerate(MANUAL_FATAWA):
        key = fatwa["question"][:80]
        if key not in existing_questions:
            fatwa["id"] = str(len(existing) + added + 1)
            fatwa["source"] = fatwa.get("book", "")
            fatwa["url"] = ""
            existing.append(fatwa)
            existing_questions.add(key)
            added += 1
            print(f"✅ أضاف: {fatwa['question'][:60]}")

    # حفظ
    os.makedirs(os.path.dirname(OUTPUT_JSON), exist_ok=True)
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump({"fatawa": existing, "total": len(existing)}, f, ensure_ascii=False, indent=2)

    print(f"\n💾 تم الحفظ: {OUTPUT_JSON}")
    print(f"📊 الإجمالي: {len(existing)} فتوى")
    print(f"➕ تمت إضافة: {added} فتوى جديدة")


if __name__ == "__main__":
    add_manual_fatawa()