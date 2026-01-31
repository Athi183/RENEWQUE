from fastapi import FastAPI, UploadFile, File, Form
import requests
import os
import uuid
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles

load_dotenv()

app = FastAPI()

os.makedirs("outputs", exist_ok=True)
app.mount("/static", StaticFiles(directory="outputs"), name="static")

HF_TOKEN = os.getenv("HF_TOKEN")
MODEL_URL = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1"

headers = {
    "Authorization": f"Bearer {HF_TOKEN}",
}

@app.post("/redesign")
async def redesign(
    image: UploadFile = File(...),
    prompt: str = Form(...)
):
    response = requests.post(
        MODEL_URL,
        headers=headers,
        json={
            "inputs": prompt,
            "parameters": {
                "num_inference_steps": 20,
                "guidance_scale": 7,
                "width": 512,
                "height": 512
            }
        }
    )

    filename = f"{uuid.uuid4()}.png"
    path = f"outputs/{filename}"

    with open(path, "wb") as f:
        f.write(response.content)

    return {
        "image_url": f"http://127.0.0.1:8000/static/{filename}"
    }
