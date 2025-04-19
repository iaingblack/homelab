import fitz  # PyMuPDF
import json
import requests
from tqdm import tqdm

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL_NAME = "llama3.2:1b"  # or whatever model you've pulled with `ollama pull`

def extract_text_from_pdf(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text

def chunk_text(text, max_tokens=500):
    paragraphs = text.split('\n')
    chunks, current = [], ""
    for p in paragraphs:
        if len(current) + len(p) < max_tokens * 4:
            current += p + "\n"
        else:
            chunks.append(current.strip())
            current = p + "\n"
    if current:
        chunks.append(current.strip())
    return chunks

def query_ollama(prompt):
    response = requests.post(OLLAMA_URL, json={
        "model": MODEL_NAME,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False
    })
    response.raise_for_status()
    return response.json()["message"]["content"]

def generate_qa(text_chunk):
    prompt = f"""Based on the following text, generate 3 question and answer pairs that would help someone understand the material better.

Text:
{text_chunk}

Format:
Q1: ...
A1: ...
Q2: ...
A2: ...
Q3: ...
A3: ...
"""
    return query_ollama(prompt)

def parse_qa_pairs(raw_text):
    lines = raw_text.strip().split('\n')
    qa_pairs = []
    current_q = current_a = None
    for line in lines:
        if line.lower().startswith("q"):
            if current_q and current_a:
                qa_pairs.append((current_q, current_a))
            current_q = line.split(":", 1)[-1].strip()
            current_a = None
        elif line.lower().startswith("a"):
            current_a = line.split(":", 1)[-1].strip()
    if current_q and current_a:
        qa_pairs.append((current_q, current_a))
    return qa_pairs

def main():
    pdf_path = "BitcoinForDummies.pdf"
    full_text = extract_text_from_pdf(pdf_path)
    chunks = chunk_text(full_text)

    all_qa = []

    for chunk in tqdm(chunks, desc="Generating QA pairs"):
        try:
            result = generate_qa(chunk)
            qa_pairs = parse_qa_pairs(result)
            for q, a in qa_pairs:
                all_qa.append({
                    "messages": [
                        {"role": "user", "content": q},
                        {"role": "assistant", "content": a}
                    ]
                })
        except Exception as e:
            print(f"Error: {e}")

    with open("bitcoin_qa_finetune.jsonl", "w") as f:
        for item in all_qa:
            f.write(json.dumps(item) + "\n")

    print(f"✅ Saved {len(all_qa)} QA pairs to bitcoin_qa_finetune.jsonl")

if __name__ == "__main__":
    main()
