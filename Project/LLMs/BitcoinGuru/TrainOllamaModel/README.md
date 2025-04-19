Doesn't work on mac, ugh. the requirements needs wheel etc...

## Python

```
python -m venv venv
chmod +x ./venv/bin/activate
. ./venv/bin/activate
pip install -r requirements.txt --prefer-binary
```

For this part it will download this model. Seems unavoidable.

```bash
huggingface-cli login  # if needed
huggingface-cli download unsloth/mistral-7b-instruct-v0.2
```


# ChatGPT Notes

