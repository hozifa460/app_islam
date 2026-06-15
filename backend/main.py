# backend/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
import numpy as np
import json
import os
from typing import Optional

app = FastAPI(title="Fatawa Search API", version="1.0.0")

# السماح للتطبيق بالاتصال
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ══════════════════════════════════════
# تحميل النموذج والبيانات
# ══════════════════════════════════════
print("⏳ تحميل النموذج...")
model = SentenceTransformer(
    'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'
)
print("✅ تم تحميل النموذج")

# تحميل الفتاوى
with open('fatawa_with_embeddings.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
    fatawa = data['fatawa']

# تحويل embeddings إلى numpy
fatawa_embeddings = np.array([f['embedding'] for f in fatawa])
print(f"✅ تم تحميل {len(fatawa)} فتوى")


# ══════════════════════════════════════
# النماذج
# ══════════════════════════════════════
class SearchRequest(BaseModel):
    query: str
    top_k: int = 10
    scholar: Optional[str] = None
    category: Optional[str] = None
    min_score: float = 0.25


class FatwaResult(BaseModel):
    id: str
    question: str
    answer: str
    scholar: str
    book: str
    category: str
    score: float


# ══════════════════════════════════════
# نقاط النهاية
# ══════════════════════════════════════
@app.get("/")
def root():
    return {"message": "Fatawa Search API", "total_fatawa": len(fatawa)}


@app.post("/search")
async def search(request: SearchRequest):
    if not request.query.strip():
        raise HTTPException(status_code=400, detail="الاستعلام فارغ")

    # توسيع الاستعلام
    expanded_queries = expand_query(request.query)

    # جمع النتائج من كل الاستعلامات
    all_scores = np.zeros(len(fatawa))

    for q in expanded_queries:
        query_embedding = model.encode([q])[0]
        scores = cosine_similarity(fatawa_embeddings, query_embedding)
        all_scores = np.maximum(all_scores, scores)

    # تطبيق الفلاتر
    filtered_indices = []
    for i, fatwa in enumerate(fatawa):
        if all_scores[i] < request.min_score:
            continue
        if request.scholar and fatwa['scholar'] != request.scholar:
            continue
        if request.category and fatwa['category'] != request.category:
            continue
        filtered_indices.append(i)

    # ترتيب وإرجاع
    filtered_indices.sort(key=lambda i: all_scores[i], reverse=True)
    top_indices = filtered_indices[:request.top_k]

    results = []
    for i in top_indices:
        f = fatawa[i]
        results.append({
            'id': f['id'],
            'question': f['question'],
            'answer': f['answer'],
            'scholar': f['scholar'],
            'book': f['book'],
            'category': f['category'],
            'keywords': f.get('keywords', []),
            'score': float(all_scores[i]),
        })

    return {
        'results': results,
        'total': len(results),
        'query': request.query,
    }


@app.get("/categories")
def get_categories():
    """جلب جميع التصنيفات"""
    cats = list(set(f['category'] for f in fatawa))
    return {'categories': sorted(cats)}


@app.get("/scholars")
def get_scholars():
    """جلب جميع العلماء"""
    scholars = list(set(f['scholar'] for f in fatawa))
    return {'scholars': sorted(scholars)}


@app.get("/fatwa/{fatwa_id}")
def get_fatwa(fatwa_id: str):
    """جلب فتوى بالمعرف"""
    for f in fatawa:
        if f['id'] == fatwa_id:
            return f
    raise HTTPException(status_code=404, detail="الفتوى غير موجودة")


@app.get("/random")
def get_random_fatwa(category: Optional[str] = None):
    """فتوى عشوائية"""
    import random
    pool = fatawa
    if category:
        pool = [f for f in fatawa if f['category'] == category]
    if not pool:
        raise HTTPException(status_code=404, detail="لا توجد فتاوى")
    return random.choice(pool)


# ══════════════════════════════════════
# دوال مساعدة
# ══════════════════════════════════════
def cosine_similarity(matrix: np.ndarray, vector: np.ndarray) -> np.ndarray:
    matrix_norms = np.linalg.norm(matrix, axis=1)
    vector_norm = np.linalg.norm(vector)

    if vector_norm == 0:
        return np.zeros(len(matrix))

    dots = matrix @ vector
    return dots / (matrix_norms * vector_norm + 1e-8)


def expand_query(query: str) -> list:
    """توسيع الاستعلام بمرادفات"""
    queries = [query]

    synonyms = {
        'صلاة': ['صلى', 'يصلي', 'المصلي'],
        'زكاة': ['زكاة المال', 'إخراج الزكاة', 'الصدقة الواجبة'],
        'صيام': ['صوم', 'الصيام', 'يصوم'],
        'حج': ['الحج', 'مناسك الحج', 'الحج والعمرة'],
        'وضوء': ['الوضوء', 'يتوضأ', 'الطهارة'],
        'حرام': ['لا يجوز', 'محرم', 'ممنوع شرعاً'],
        'حلال': ['جائز', 'يجوز', 'مباح'],
        'مريض': ['المريض', 'المرض', 'العجز'],
        'مسافر': ['السفر', 'في السفر', 'الغريب'],
    }

    for word, syns in synonyms.items():
        if word in query:
            for syn in syns[:2]:
                queries.append(query.replace(word, syn))

    return queries[:4]  # أقصى 4 استعلامات