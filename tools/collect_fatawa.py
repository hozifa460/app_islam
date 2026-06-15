# tools/collect_fatawa.py
import requests
import json
import time
import os

def collect_islamqa(max_pages=100):
    """
    جمع الفتاوى من إسلام سؤال وجواب
    عندهم API رسمي مجاني بدون مفتاح
    """
    fatawa = []
    base_url = "https://islamqa.info/api/v1/ar/posts"

    categories = [
        "prayer",      # صلاة
        "fasting",     # صيام
        "zakat",       # زكاة
        "hajj",        # حج
        "purification",# طهارة
        "transactions",# معاملات
        "marriage",    # نكاح
        "beliefs",     # عقيدة
        "quran",       # قرآن
        "ethics",      # أخلاق
    ]

    for category in categories:
        page = 1
        print(f"\n📚 جمع فتاوى: {category}")

        while page <= max_pages:
            try:
                url = f"{base_url}?category={category}&page={page}&per_page=20"
                response = requests.get(url, timeout=10)

                if response.status_code != 200:
                    break

                data = response.json()
                items = data.get('data', {}).get('data', [])

                if not items:
                    break

                for item in items:
                    fatwa = {
                        'id': str(item.get('id', '')),
                        'question': item.get('title', ''),
                        'answer': item.get('content', ''),
                        'scholar': item.get('scholar', 'إسلام سؤال وجواب'),
                        'book': 'إسلام سؤال وجواب',
                        'category': category,
                        'url': f"https://islamqa.info/ar/answers/{item.get('id', '')}",
                        'keywords': [],
                        'source': 'إسلام سؤال وجواب',
                    }

                    if len(fatwa['question']) > 5 and len(fatwa['answer']) > 20:
                        fatawa.append(fatwa)

                print(f"  ✅ صفحة {page}: {len(items)} فتوى")
                page += 1

                # انتظر قليلاً لا تضغط على السيرفر
                time.sleep(0.5)

            except Exception as e:
                print(f"  ❌ خطأ: {e}")
                break

    return fatawa


def collect_dorar():
    """
    الدرر السنية - عندهم API مجاني
    """
    fatawa = []

    try:
        # API الدرر السنية
        url = "https://dorar.net/api/v1/fatawa"
        response = requests.get(url, timeout=10)

        if response.status_code == 200:
            data = response.json()
            for item in data.get('data', []):
                fatwa = {
                    'id': str(item.get('id', '')),
                    'question': item.get('title', ''),
                    'answer': item.get('body', ''),
                    'scholar': item.get('scholar', ''),
                    'book': 'الدرر السنية',
                    'category': item.get('category', 'عام'),
                    'url': item.get('url', ''),
                    'keywords': [],
                    'source': 'الدرر السنية',
                }
                if len(fatwa['question']) > 5:
                    fatawa.append(fatwa)
    except Exception as e:
        print(f"❌ خطأ الدرر: {e}")

    return fatawa


def collect_binbaz():
    """
    موقع ابن باز - فتاوى مفتوحة
    """
    fatawa = []

    for page in range(1, 50):
        try:
            url = f"https://binbaz.org.sa/api/fatwas?page={page}"
            response = requests.get(url, timeout=10)

            if response.status_code != 200:
                break

            data = response.json()
            items = data.get('data', [])

            if not items:
                break

            for item in items:
                fatwa = {
                    'id': f"binbaz_{item.get('id', '')}",
                    'question': item.get('title', ''),
                    'answer': item.get('answer', item.get('content', '')),
                    'scholar': 'الشيخ ابن باز',
                    'book': 'فتاوى ابن باز',
                    'category': item.get('category', 'عام'),
                    'url': f"https://binbaz.org.sa/fatwas/{item.get('id', '')}",
                    'keywords': [],
                    'source': 'موقع الشيخ ابن باز',
                }
                if len(fatwa['question']) > 5:
                    fatawa.append(fatwa)

            print(f"  ✅ ابن باز صفحة {page}: {len(items)}")
            time.sleep(0.3)

        except Exception as e:
            print(f"  ❌ {e}")
            break

    return fatawa


def add_keywords(fatwa):
    """إضافة كلمات مفتاحية"""
    from collections import Counter
    import re

    stop_words = {
        'في', 'من', 'على', 'عن', 'إلى', 'هل', 'ما', 'هو', 'هي',
        'أن', 'إن', 'كان', 'لا', 'لم', 'قد', 'و', 'أو', 'ثم',
        'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم',
    }

    text = f"{fatwa['question']} {fatwa['answer']}"
    words = re.findall(r'[\u0600-\u06FF]{3,}', text)
    filtered = [w for w in words if w not in stop_words]
    keywords = [w for w, _ in Counter(filtered).most_common(8)]

    fatwa['keywords'] = keywords
    return fatwa


def main():
    all_fatawa = []

    print("🚀 بدء جمع الفتاوى...")
    print("=" * 50)

    # 1. إسلام سؤال وجواب
    print("\n1️⃣ إسلام سؤال وجواب...")
    islamqa = collect_islamqa(max_pages=20)
    print(f"✅ تم جمع {len(islamqa)} فتوى")
    all_fatawa.extend(islamqa)

    # 2. الدرر السنية
    print("\n2️⃣ الدرر السنية...")
    dorar = collect_dorar()
    print(f"✅ تم جمع {len(dorar)} فتوى")
    all_fatawa.extend(dorar)

    # 3. ابن باز
    print("\n3️⃣ موقع ابن باز...")
    binbaz = collect_binbaz()
    print(f"✅ تم جمع {len(binbaz)} فتوى")
    all_fatawa.extend(binbaz)

    # إضافة كلمات مفتاحية
    print("\n🔑 إضافة كلمات مفتاحية...")
    all_fatawa = [add_keywords(f) for f in all_fatawa]

    # إزالة المكرر
    seen = set()
    unique = []
    for f in all_fatawa:
        key = f['question'][:50]
        if key not in seen and len(f['question']) > 5:
            seen.add(key)
            unique.append(f)

    print(f"\n🗑️ تم حذف {len(all_fatawa) - len(unique)} مكرر")
    print(f"📊 إجمالي الفتاوى الفريدة: {len(unique)}")

    # حفظ
    os.makedirs('assets/json', exist_ok=True)
    with open('assets/json/fatawa_main.json', 'w', encoding='utf-8') as f:
        json.dump({'fatawa': unique, 'total': len(unique)}, f,
                  ensure_ascii=False, indent=2)

    print(f"\n✅ تم الحفظ في assets/json/fatawa_main.json")
    print("🎉 انتهى!")


if __name__ == '__main__':
    main()