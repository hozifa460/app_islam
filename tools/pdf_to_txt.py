# tools/pdf_to_txt.py
import fitz  # pymupdf

def pdf_to_txt(pdf_path, output_path):
    doc = fitz.open(pdf_path)
    full_text = ""

    for i, page in enumerate(doc):
        # هذه الطريقة أقوى بكثير من PyPDF2
        text = page.get_text("text")
        full_text += text + "\n"

        if (i + 1) % 50 == 0:
            print(f"✅ تمت معالجة {i+1} صفحة...")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(full_text)

    print(f"💾 تم الحفظ في: {output_path}")
    print(f"📊 حجم النص: {len(full_text)} حرف")

    # اطبع أول 500 حرف للتحقق
    print("\n🔍 أول 500 حرف من النص:")
    print(full_text[:500])

pdf_to_txt(
    r'books\ibn_uthaimine_1_text.pdf',
    r'books\ibn_uthaimine_1.txt'
)