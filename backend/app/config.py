from dotenv import load_dotenv
import os

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
HUGGINGFACE_API_KEY = os.getenv("HUGGINGFACE_API_KEY")

if not GROQ_API_KEY or not HUGGINGFACE_API_KEY:
    raise RuntimeError("Missing API keys in .env")
