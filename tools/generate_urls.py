import os
import json
import requests
import time

HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json",
}

OUTPUT_JSON = "assets/json/fatawa_main.json"


def fetch_dorar_fatawa():
    """
    الدرر السنية - API مجاني ورسمي
    يعطي آلاف الفتاوى
    """
    all_fatawa = []
    page = 1
    max_pages = 200

    print("📚 جمع من الدرر السنية...")

    while page <= max_pages:
        try:
            url = f"https://dorar.net/api/v1/hadith?page={page}&limit=50"
            r = requests.get(url, headers=HEADERS, timeout=15)

            if r.status_code != 200:
                break

            data = r.json()
            items = data.get("data", [])

            if not items:
                break

            for item in items:
                fatwa = {
                    "id": str(item.get("id", "")),
                    "question": item.get("hadith", "")[:200],
                    "answer": item.get("hadith", ""),
                    "scholar": item.get("book", {}).get("name", "الدرر السنية"),
                    "book": "الدرر السنية",
                    "category": "حديث",
                    "keywords": [],
                    "source": "الدرر السنية",
                    "url": f"https://dorar.net/hadith/{item.get('id', '')}",
                }
                if len(fatwa["question"]) > 5:
                    all_fatawa.append(fatwa)

            print(f"  ✅ صفحة {page}: {len(items)} عنصر")
            page += 1
            time.sleep(0.5)

        except Exception as e:
            print(f"  ❌ خطأ صفحة {page}: {e}")
            break

    print(f"✅ الدرر السنية: {len(all_fatawa)}")
    return all_fatawa


def fetch_islamweb_categories():
    """
    إسلام ويب - جمع عبر تصفح الصفحات
    """
    import re
    from bs4 import BeautifulSoup

    all_fatawa = []

    # صفحات فتاوى إسلام ويب المباشرة
    category_urls = [
        "https://www.islamweb.net/ar/fatwa/index.php?page=1",
        "https://www.islamweb.net/ar/fatwa/index.php?page=2",
        "https://www.islamweb.net/ar/fatwa/index.php?page=3",
    ]

    print("📚 جمع من إسلام ويب...")

    for cat_url in category_urls:
        try:
            r = requests.get(cat_url, headers={
                "User-Agent": "Mozilla/5.0",
                "Accept-Language": "ar",
            }, timeout=15)

            if r.status_code != 200:
                continue

            soup = BeautifulSoup(r.text, "html.parser")

            # استخراج روابط الفتاوى
            links = soup.find_all("a", href=True)
            fatwa_links = [
                l["href"] for l in links
                if "/ar/fatwa/" in l["href"] and l["href"].count("/") >= 4
            ]

            for link in fatwa_links[:20]:
                full_url = link if link.startswith("http") else f"https://www.islamweb.net{link}"
                r2 = requests.get(full_url, headers={"User-Agent": "Mozilla/5.0"}, timeout=15)

                if r2.status_code != 200:
                    continue

                soup2 = BeautifulSoup(r2.text, "html.parser")

                title = ""
                h1 = soup2.find("h1")
                if h1:
                    title = h1.get_text(strip=True)

                paras = [p.get_text(strip=True) for p in soup2.find_all("p") if len(p.get_text(strip=True)) > 40]
                content = "\n".join(paras[:15])

                if len(title) > 5 and len(content) > 80:
                    all_fatawa.append({
                        "id": str(len(all_fatawa) + 1),
                        "question": title,
                        "answer": content,
                        "scholar": "إسلام ويب",
                        "book": "إسلام ويب",
                        "category": "عام",
                        "keywords": [],
                        "source": "إسلام ويب",
                        "url": full_url,
                    })

                time.sleep(1)

        except Exception as e:
            print(f"❌ خطأ: {e}")

    print(f"✅ إسلام ويب: {len(all_fatawa)}")
    return all_fatawa


def load_existing():
    """تحميل الفتاوى الموجودة"""
    if os.path.exists(OUTPUT_JSON):
        with open(OUTPUT_JSON, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("fatawa", [])
    return []


def save_fatawa(fatawa):
    """حفظ الفتاوى"""
    os.makedirs(os.path.dirname(OUTPUT_JSON), exist_ok=True)

    # إزالة المكرر
    seen = set()
    unique = []
    for f in fatawa:
        key = f["question"][:100]
        if key not in seen:
            seen.add(key)
            unique.append(f)

    for i, f in enumerate(unique, 1):
        f["id"] = str(i)

    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump({"fatawa": unique, "total": len(unique)}, f, ensure_ascii=False, indent=2)

    print(f"\n💾 تم الحفظ: {OUTPUT_JSON}")
    print(f"📊 الإجمالي: {len(unique)} فتوى")


def main():
    print("🚀 بدء جمع الفتاوى...")
    print("=" * 50)

    # تحميل القديم
    existing = load_existing()
    print(f"📂 فتاوى سابقة: {len(existing)}")

    all_fatawa = list(existing)
    existing_urls = {f.get("url", "") for f in existing}

    # جمع جديد
    new_fatawa = []

    # 1. الدرر السنية
    dorar = fetch_dorar_fatawa()
    for f in dorar:
        if f.get("url", "") not in existing_urls:
            new_fatawa.append(f)

    # 2. إسلام ويب
    islamweb = fetch_islamweb_categories()
    for f in islamweb:
        if f.get("url", "") not in existing_urls:
            new_fatawa.append(f)

    print(f"\n✅ فتاوى جديدة: {len(new_fatawa)}")

    all_fatawa.extend(new_fatawa)
    save_fatawa(all_fatawa)

    print("\n🎉 انتهى!")


if __name__ == "__main__":
    main()