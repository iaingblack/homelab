# Fine Tune a LLM Locally

The scripts can fine tune an LLM using Ollama. Steps are below

## Ollama

Download and install it

Then pull this image
```
ollama pull llama3.1:8b
ollama pull nomic-embed-text
```

```bash
ollama serve
```

## Python

```
python -m venv venv
chmod +x ./venv/bin/activate
. ./venv/bin/activate
pip install -r requirements.txt
```