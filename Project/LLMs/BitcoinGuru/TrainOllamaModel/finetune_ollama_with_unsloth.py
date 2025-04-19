from unsloth import FastLanguageModel
from datasets import load_dataset, Dataset
from transformers import TrainingArguments
from trl import SFTTrainer
import json

MODEL_NAME = "unsloth/mistral-7b-instruct-v0.2"  # base model
NEW_MODEL_DIR = "fine-tuned-mistral-bitcoin"     # output

# 1. Load dataset
def load_jsonl_to_dataset(jsonl_file):
    data = []
    with open(jsonl_file, 'r') as f:
        for line in f:
            item = json.loads(line)
            user = item["messages"][0]["content"]
            assistant = item["messages"][1]["content"]
            prompt = f"<|user|>\n{user}\n<|assistant|>\n{assistant}"
            data.append({"prompt": prompt})
    return Dataset.from_list(data)

dataset = load_jsonl_to_dataset("bitcoin_qa_finetune.jsonl")

# 2. Load model with Unsloth
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=MODEL_NAME,
    max_seq_length=2048,
    dtype=None,  # "auto" = fp16/bf16 automatically
    load_in_4bit=True  # works on consumer GPUs
)

# 3. Add special tokens
FastLanguageModel.for_inference(model)

# 4. Define training arguments
training_args = TrainingArguments(
    output_dir=NEW_MODEL_DIR,
    num_train_epochs=2,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    logging_steps=10,
    save_strategy="epoch",
    learning_rate=2e-5,
    fp16=True,
    save_total_limit=1,
    report_to="none",
)

# 5. Train with SFTTrainer
trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="prompt",
    args=training_args,
    max_seq_length=2048,
    packing=True,
)
trainer.train()

# 6. Save final model
trainer.model.save_pretrained(NEW_MODEL_DIR)
tokenizer.save_pretrained(NEW_MODEL_DIR)

print(f"✅ Fine-tuned model saved to {NEW_MODEL_DIR}")
