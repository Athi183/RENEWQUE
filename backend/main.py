import os
import uuid
import base64
import requests
from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles

# Setup paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load Hugging Face token
load_dotenv()
HF_TOKEN = os.getenv("HF_TOKEN")

# FastAPI app
app = FastAPI()
app.mount("/static", StaticFiles(directory=OUTPUT_DIR), name="static")

# Hugging Face router endpoint
MODEL_URL = "https://router.huggingface.co/hf-inference/models/timbrooks/instruct-pix2pix"
headers = {"Authorization": f"Bearer {HF_TOKEN}"}


@app.post("/redesign")
async def redesign(image: UploadFile = File(...), prompt: str = Form(...)):
    # Read uploaded image
    image_bytes = await image.read()
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")

    # Send request to Hugging Face router
    response = requests.post(
        MODEL_URL,
        headers=headers,
        json={
            "inputs": prompt,
            "image": image_b64
        }
    )

    # Debug logging
    print("Response status:", response.status_code)
    print("Response headers:", response.headers)
    try:
        print("Response text snippet:", response.text[:500])
    except Exception:
        pass

    # Case 1: raw image returned
    if response.headers.get("content-type", "").startswith("image"):
        filename = f"{uuid.uuid4()}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "wb") as f:
            f.write(response.content)
        return {"image_url": f"http://10.208.19.187:8000/static/{filename}"}

    # Case 2: JSON with base64 image(s)
    try:
        data = response.json()
        image_base64 = None

        # Hugging Face sometimes returns a list
        if isinstance(data, list) and "generated_image" in data[0]:
            image_base64 = data[0]["generated_image"]
        elif "generated_images" in data:
            image_base64 = data["generated_images"][0]

        if image_base64:
            image_bytes = base64.b64decode(image_base64)
            filename = f"{uuid.uuid4()}.png"
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, "wb") as f:
                f.write(image_bytes)
            return {"image_url": f"http://10.208.19.187:8000/static/{filename}"}

        return {"error": data}
    except Exception:
        return {"error": response.text}
