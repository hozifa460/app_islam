# backend/generate_embeddings.py
# سكريبت إنشاء الـ Embeddings (شغّله مرة واحدة فقط)

from sentence_transformers import SentenceTransformer
import json
import numpy as np

def generate_embeddings():
    print("⏳ تحميل النموذج...")
    model = SentenceTransformer(
        'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'
    )

    with open('../assets/fatawa_main.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fatawa = data['fatawa']
    print(f"📊 عدد الفتاوى: {len(fatawa)}")

    # إنشاء نصوص للتحويل
    texts = []
    for f in fatawa:
        text = f"{f['question']} {f['answer'][:300]}"
        texts.append(text)

    # التحويل دفعة دفعة لتجنب نفاد الذاكرة
    batch_size = 32
    all_embeddings = []

    for i in range(0, len(texts), batch_size):
        batch = texts[i:i+batch_size]
        embeddings = model.encode(batch, show_progress_bar=False)
        all_embeddings.extend(embeddings.tolist())
        print(f"✅ {min(i+batch_size, len(texts))}/{len(texts)}")

    # إضافة embeddings للفتاوى
    for i, fatwa in enumerate(fatawa):
        fatwa['embedding'] = all_embeddings[i]

    # حفظ
    with open('fatawa_with_embeddings.json', 'w', encoding='utf-8') as f:
        json.dump({'fatawa': fatawa}, f, ensure_ascii=False)

    print(f"✅ تم الحفظ: fatawa_with_embeddings.json")


if __name__ == '__main__':
    generate_embeddings()