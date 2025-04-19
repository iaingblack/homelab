

Key Changes and Notes:

Replaced OpenAI with Ollama from llama_index.llms.ollama.
Specified the local model (e.g., llama3.1:8b). Change this to match the model you pulled in Ollama (run ollama list to check available models).
Set request_timeout=120.0 to handle potential delays with local inference. Adjust if needed.
The script limits processing to the first 10 chunks (nodes[:10]) to avoid overloading your local system during testing. Remove or adjust this limit for full processing.
Ensure Ollama is running (ollama serve) before executing the script.
Performance depends on your hardware (GPU recommended for larger models like Llama-3.1-8B). If you encounter memory issues, try a smaller model (e.g., llama3.1:8b with quantization) or reduce chunk_size.