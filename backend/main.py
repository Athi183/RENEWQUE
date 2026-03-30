from fastapi import FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from PIL import Image
import io
import os
import requests
import base64
import urllib.parse
from urllib.parse import quote
from dotenv import load_dotenv
import numpy as np
import uuid
import time

# ── Optional: tensorflow (for fabric sustainability prediction) ──
try:
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
    os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
    import tensorflow as tf
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False

try:
    import google.generativeai as genai
    from groq import Groq
    AI_TOOLS_AVAILABLE = True
except ImportError:
    AI_TOOLS_AVAILABLE = False

# ── Optional: new google-genai SDK (for image generation) ──
try:
    from google import genai as google_genai_new
    from google.genai import types as genai_types
    NEW_GENAI_AVAILABLE = True
except ImportError:
    NEW_GENAI_AVAILABLE = False

# ── Optional: torch (for similarity search) ──
try:
    import torch
    import torch.nn.functional as F
    from torchvision import models, transforms
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False

# ──────────────────────────────────────────────────────────────────
#  Server Configuration & Paths
# ──────────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(os.path.dirname(BASE_DIR), ".env")
load_dotenv(env_path)
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
MODEL_H5 = os.path.join(BASE_DIR, "fabric_model.h5")
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
os.makedirs(OUTPUT_DIR, exist_ok=True)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", os.getenv("GEMINI_API", os.getenv("GOOGLE_API_KEY", os.getenv("API_KEY", ""))))
GROQ_API_KEY   = os.getenv("GROQ_API", os.getenv("API_KEY", ""))
HF_TOKEN       = os.getenv("HF_TOKEN", "")

if AI_TOOLS_AVAILABLE and GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
if AI_TOOLS_AVAILABLE and GROQ_API_KEY:
    groq_client = Groq(api_key=GROQ_API_KEY)
else:
    groq_client = None

app = FastAPI(title="Renewque Sustainability AI")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory=OUTPUT_DIR), name="static")

# ──────────────────────────────────────────────────────────────────
#  Sustainability Model (Risk Analysis) Logic
# ──────────────────────────────────────────────────────────────────
_model = None
if TF_AVAILABLE and os.path.exists(MODEL_H5):
    print("⏳  Loading fabric_model.h5 for Risk Analysis…")
    try:
        _model = tf.keras.models.load_model(MODEL_H5, compile=False)
        _INPUT_H = _model.input_shape[1] or 224
        _INPUT_W = _model.input_shape[2] or 224
        _NUM_CLASSES = _model.output_shape[-1]
        print(f"✅  Sustainability Model loaded | input=({_INPUT_H},{_INPUT_W},3) | classes={_NUM_CLASSES}")
    except Exception as e:
        print(f"⚠️  Sustainability model load failed: {e}")

FABRIC_CLASSES = [
    (0, "Cotton", 5.9, 10000, 0.32, 0.55),
    (1, "Linen", 1.7, 2500, 0.18, 0.22),
    (2, "Hemp", 1.2, 2300, 0.12, 0.18),
    (3, "Polyester", 9.5, 125, 0.45, 0.78),
    (4, "Nylon", 14.2, 140, 0.52, 0.88),
    (5, "Viscose/Rayon", 4.3, 7800, 0.28, 0.62),
    (6, "Wool", 5.5, 5600, 0.38, 0.60),
    (7, "Silk", 3.8, 7600, 0.24, 0.55),
    (8, "Acrylic", 12.0, 130, 0.50, 0.84),
    (9, "Denim/Jean", 6.4, 11000, 0.40, 0.67),
    (10, "Leather", 8.7, 17000, 0.48, 0.80),
    (11, "Recycled Polyester", 3.1, 90, 0.20, 0.35),
    (12, "Tencel/Lyocell", 1.9, 2000, 0.15, 0.24),
]

def _weighted_metrics(probabilities: np.ndarray) -> dict:
    carbon = water = waste = eis = 0.0
    fabric_scores = []
    for idx, name, c, w, ws, e in FABRIC_CLASSES:
        p = float(probabilities[idx])
        carbon += p * c
        water  += p * w
        waste  += p * ws
        eis    += p * e
        fabric_scores.append({"name": name, "confidence": round(p * 100, 1)})
    
    # Get top 3 most likely fabrics
    top_fabrics = sorted(fabric_scores, key=lambda x: x["confidence"], reverse=True)[:3]
    
    # Filter out fabrics with essentially 0% confidence
    top_fabrics = [f for f in top_fabrics if f["confidence"] > 0.0]

    eis = float(np.clip(eis, 0.0, 1.0))
    return {
        "carbon": round(carbon, 2),
        "water": round(water, 1),
        "waste": round(waste, 3),
        "eis": round(eis, 3),
        "top_fabrics": top_fabrics,
    }

def _generate_ai_explanation(metrics: dict, detected_fabric: str, risk: str) -> str:
    """Use Groq to generate a human-friendly explanation of the sustainability score."""
    if not groq_client: 
        return f"This {detected_fabric} garment has a {risk} sustainability risk based on its estimated resource usage."

    try:
        prompt = (
            f"You are RenewQue, an expert in sustainable fashion. Using a multi-modal high-resolution image analysis, "
            f"we have verified that this is a {detected_fabric} garment. "
            f"Explain why it has a {risk} risk level based on these metrics:\n"
            f"- Carbon Footprint: {metrics['carbon']} kg CO2\n"
            # Limit the prompt to be concise
            f"- Water Usage: {metrics['water']} Liters\n"
            f"- Waste: {metrics['waste']} kg\n"
            f"- Impact Score (EIS): {metrics['eis']}\n\n"
            "Provide 2-3 sentences that are helpful, encouraging, and explain the main driver of this score. "
            "Keep it under 60 words and professional yet friendly."
        )

        chat = groq_client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a helpful, concise sustainable fashion expert."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=100,
            temperature=0.7
        )
        return chat.choices[0].message.content.strip()
    except Exception as e:
        print(f"⚠️ AI Explanation failed: {e}")
        return f"This {detected_fabric} item has a {risk} risk level due to its carbon and water footprint."

def _risk_level(eis: float) -> str:
    if eis >= 0.60: return "High"
    elif eis >= 0.35: return "Medium"
    return "Low"

def _preprocess_image(image_bytes: bytes) -> np.ndarray:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((224, 224), Image.LANCZOS)
    arr = np.array(img, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)

def _verify_fabric_with_vision(image_bytes: bytes, top_detected: str) -> str:
    """Use Gemini Vision to identify the fabric texture with high accuracy (Multi-Modal)."""
    if not AI_TOOLS_AVAILABLE or not GEMINI_API_KEY:
        return top_detected

    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        prompt = (
            f"Compare this image with the initial guess of '{top_detected}'. "
            "Examine texture, sheen, drape, and weave. "
            "If it's definitely Satin, Silk, Velvet, Organza, or another specific material, state that. "
            "If it's exactly what the model thought, just return '{top_detected}'. "
            "Return ONLY the confirmed fabric name (e.g. 'Satin Dress')."
        )
        
        response = model.generate_content([img, prompt])
        res_text = response.text.strip().replace('"', '')
        
        # If it returned a long sentence, clean it
        if "is" in res_text.lower():
            res_text = res_text.split("is")[-1].strip().strip(".")

        print(f"👁️ Vision Verification: {top_detected} -> {res_text}")
        return res_text
    except Exception as e:
        print(f"⚠️ Vision Verification failed: {e}")
        return top_detected

# ──────────────────────────────────────────────────────────────────
#  Similarity Search logic (Torch / Similarity)
# ──────────────────────────────────────────────────────────────────

def _build_image_index():
    """Build a filename -> absolute path lookup for serving recommendation previews."""
    candidate_dirs = []
    env_dir = os.getenv("IMAGE_DATASET_DIR", "").strip()
    if env_dir:
        candidate_dirs.append(env_dir)
    candidate_dirs.extend([
        os.path.join(BASE_DIR, "images"),
        os.path.join(BASE_DIR, "dataset"),
        os.path.join(BASE_DIR, "outputs"),
    ])
    image_map = {}
    for root_dir in candidate_dirs:
        if not root_dir or not os.path.isdir(root_dir):
            continue
        for root, _, files in os.walk(root_dir):
            for name in files:
                ext = os.path.splitext(name)[1].lower()
                if ext in IMAGE_EXTS and name not in image_map:
                    image_map[name] = os.path.join(root, name)
    return image_map

image_index = _build_image_index()
torch_model = None
torch_transform = None
embedding_vectors = None
image_names = []

if TORCH_AVAILABLE:
    try:
        _emb_path = os.path.join(BASE_DIR, "fashion_embeddings.pth")
        if os.path.exists(_emb_path):
            embeddings = torch.load(_emb_path)
            image_names = list(embeddings.keys())
            embedding_vectors = torch.stack(list(embeddings.values()))
        _m = models.efficientnet_b0(pretrained=True)
        torch_model = torch.nn.Sequential(_m.features, torch.nn.AdaptiveAvgPool2d(1), torch.nn.Flatten())
        torch_model.eval()
        torch_transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
    except Exception as e:
        print(f"⚠️ Torch setup failed: {e}")

# ──────────────────────────────────────────────────────────────────
#  API Endpoints
# ──────────────────────────────────────────────────────────────────

@app.post("/predict")
async def predict_sustainability(image: UploadFile = File(...)):
    """[Risk Analysis] Fabric-based sustainability prediction (FastAPI Sustainability AI)."""
    if not TF_AVAILABLE or _model is None:
        raise HTTPException(status_code=503, detail="Sustainability AI unavailable.")
    try:
        image_bytes = await image.read()
        tensor = _preprocess_image(image_bytes)
        probs = _model.predict(tensor, verbose=0)[0]
    except Exception as e:
        raise HTTPException(status_code=422, detail=f"Inference failed: {e}")

    metrics = _weighted_metrics(probs)
    risk = _risk_level(metrics["eis"])
    top_idx = int(np.argmax(probs))
    keras_name = FABRIC_CLASSES[top_idx][1]

    # Vision-Modal Verification (Second Opinion)
    vision_name = _verify_fabric_with_vision(image_bytes, keras_name)
    final_name = vision_name or keras_name

    # Generate dynamic AI explanation based on the Vision-verified fabric name
    explanation = _generate_ai_explanation(metrics, final_name, risk)

    return JSONResponse(content={
        "Carbon": metrics["carbon"],
        "Water": metrics["water"],
        "Waste": metrics["waste"],
        "EIS": metrics["eis"],
        "Risk_Level": risk,
        "detected_fabric": final_name,
        "explanation": explanation,
        "confidence_breakdown": metrics["top_fabrics"],
        "keras_prediction": keras_name, # keep original for transparency
        "class_probs": [round(float(p), 4) for p in probs],
    })

@app.post("/similarity")
async def similarity_search(request: Request, file: UploadFile = File(...)):
    """Similarity search using EfficientNet embeddings."""
    if not TORCH_AVAILABLE or torch_model is None or embedding_vectors is None:
        raise HTTPException(status_code=503, detail="Similarity search unavailable.")
    contents = await file.read()
    img = Image.open(io.BytesIO(contents)).convert("RGB")
    img_t = torch_transform(img).unsqueeze(0)
    with torch.no_grad():
        query_embedding = torch_model(img_t)
    similarities = F.cosine_similarity(query_embedding, embedding_vectors)
    top_indices = similarities.topk(5).indices
    results = []
    for idx in top_indices:
        image_name = image_names[idx]
        image_url = f"{request.base_url}images/{quote(image_name)}" if image_name in image_index else None
        results.append({"name": image_name, "score": float(similarities[idx]), "image_url": image_url})
    return {"similar_images": results}

@app.get("/images/{image_name:path}")
async def get_image(image_name: str):
    filename = os.path.basename(image_name)
    image_path = image_index.get(filename)
    if not image_path or not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Image not found")
    return FileResponse(image_path)

# ── Redesign: Pipeline Step 1 (Advanced) – Vision Analysis with Fallbacks ──
def analyze_image_with_groq_vision(image_bytes: bytes) -> str:
    """Backup: Use Groq Llama 3.2 Vision if Gemini is exhausted/offline."""
    if not groq_client: return None
    try:
        print("🚀 Gemini hit quota/error. Trying Groq Vision (Llama 3.2)...")
        import base64
        b64_img = base64.b64encode(image_bytes).decode('utf-8')
        response = groq_client.chat.completions.create(
            model="llama-3.2-90b-vision-preview",
            messages=[{
                "role": "user",
                "content": [
                    {"type": "text", "text": "Describe this garment precisely for a fashion redesign: type, material, color, and style. 2 paragraphs."},
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64_img}"}}
                ]
            }]
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        print(f"⚠️ Groq Vision failed: {e}")
        return None

def analyze_image_with_gemini(image_bytes: bytes) -> str:
    """Robust analysis with Gemini models -> Discovery -> Groq Vision Fallback."""
    potential_models = [
        "gemini-2.5-flash",
        "gemini-3-flash",
        "gemini-2.0-flash",
        "gemini-2.0-flash-lite",
        "gemini-1.5-flash",
        "gemini-1.5-pro"
    ]
    last_error = None
    
    # 1. Try Primary Gemini Models
    for model_name in potential_models:
        try:
            print(f"🤖 Trying Gemini model: {model_name}...", flush=True)
            model = genai.GenerativeModel(model_name)
            img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            response = model.generate_content([
                img,
                ("You are a high-end luxury fashion consultant. Analyze this garment with extreme precision. "
                 "Provide a 'Hyper-Description' covering: 1. DNA/Type, 2. Material/Texture, 3. Color, 4. Hardware/Details. "
                 "Return 2-3 concise paragraphs.")
            ])
            res_text = response.text.strip()
            print(f"📝 Gemini description: {res_text}", flush=True)
            return res_text
        except Exception as e:
            msg = str(e).lower()
            print(f"⚠️ {model_name} unavailable: {e}", flush=True)
            last_error = e
            if "429" in msg or "quota" in msg:
                time.sleep(0.5)
            continue

    # 2. Try Smart Discovery (list all models available to this key)
    try:
        available = [m.name.replace("models/", "") for m in genai.list_models() 
                     if 'generateContent' in m.supported_generation_methods]
        for model_name in available:
            if model_name in potential_models: continue
            try:
                print(f"🚀 Trying discovered model: {model_name}", flush=True)
                model = genai.GenerativeModel(model_name)
                response = model.generate_content([
                    Image.open(io.BytesIO(image_bytes)).convert("RGB"),
                    "Describe this garment simply including material and color."
                ])
                return response.text.strip()
            except: continue
    except: pass

    # 3. FINAL FALLBACK: Groq Vision
    groq_res = analyze_image_with_groq_vision(image_bytes)
    if groq_res:
        return groq_res

    print("⚠️ All Vision AI models failed. Using basic fallback.", flush=True)
    return "a stylish fashion garment"

# ── Redesign: Pipeline Step 2 – Groq Prompt Engineering ──
def build_sd_prompt_with_groq(gemini_description: str, user_idea: str) -> str:
    """Use Groq to turn the visual description + user idea into a Stable Diffusion prompt."""
    if not groq_client: return f"Redesigned {user_idea}"
    system_msg = (
        "You are a Stable Diffusion prompt engineer for high-end fashion REDESIGN. "
        "Your goal is to produce a HYPER-REALISTIC visual description of the final redesign. NO narrative text.\n\n"
        "MANDATORY TEMPLATE (Follow this exactly):\n"
        "1. START WITH: '[Color] [Material] [Exact Garment Type] on a professional wooden mannequin.'\n"
        "2. GARMENT TYPE: Always use the exact name from the 'Redesign idea' (e.g., if it says 'shirt', the prompt starts with 'A shirt').\n"
        "3. MICRO-DETAILS: Include details like fine stitching, fabric weight, natural draping, and texture depth to increase realism.\n"
        "4. NO PEOPLE: Explicitly state 'No human models, zero humans'.\n"
        "5. STAGING: 'Displayed in a luxury 8k fashion studio with neutral grey background and professional high-end boutique lighting.'\n"
        "MAX 75 WORDS. Return ONLY the direct visual prompt."
    )
    chat = groq_client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "system", "content": system_msg},
                  {"role": "user", "content": f"Original: {gemini_description}\nRedesign idea: {user_idea}"}]
    )
    res_prompt = chat.choices[0].message.content.strip()
    print(f"🎨 SD prompt: {res_prompt}")
    return res_prompt

# ── Redesign: Pipeline Step 3 – Pollinations Image Generation ──
def generate_image_url_pollinations(prompt: str) -> str:
    clean_prompt = prompt.strip().replace('"', '')[:250]
    encoded = urllib.parse.quote(clean_prompt)
    # Removing hardcoded public_key to avoid 403 Forbidden errors.
    # Using public pool for generation.
    url = f"https://gen.pollinations.ai/image/{encoded}?model=flux&width=512&height=768&nologo=true"
    print(f"🌐 Pollinations URL: {url[:80]}...")
    return url

# ── Redesign: Pipeline Step 4 – Groq Fashion Advice ──
def get_groq_advice(gemini_description: str, user_idea: str) -> str:
    if not groq_client: return "Here is your redesigned outfit!"
    system_msg = ("You are RenewQue, a sustainable fashion redesign assistant. "
                  "Give 2-3 sentences of friendly fashion redesign advice. "
                  "Mention materials, sustainability tips, and styling.")
    chat = groq_client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "system", "content": system_msg},
                  {"role": "user", "content": f"Garment: {gemini_description}\nIdea: {user_idea}"}]
    )
    return chat.choices[0].message.content.strip()

@app.post("/redesign")
async def redesign(file: UploadFile = File(...), prompt: str = Form(default="modern style")):
    print(f"📥 Received redesign request: prompt='{prompt}'", flush=True)
    try:
        image_bytes = await file.read()
        print(f"📸 Image read successfully: {len(image_bytes)} bytes", flush=True)

        # Step 1: Gemini Vision analysis
        print("🤖 Analyzing with Gemini Vision...", flush=True)
        gemini_desc = analyze_image_with_gemini(image_bytes)

        # Step 2a: Build rich SD prompt via Groq
        print("🔧 Building SD prompt with Groq...")
        sd_prompt = build_sd_prompt_with_groq(gemini_desc, prompt)

        # Step 2b: Get friendly advice from Groq
        print("💡 Getting fashion advice from Groq...")
        advice = get_groq_advice(gemini_desc, prompt)

        # Step 3: Generate image URL with Pollinations (Flux model)
        print("🎨 Generating image with Pollinations Flux...")
        image_url = generate_image_url_pollinations(sd_prompt)

        print("✅ Redesign completed successfully.", flush=True)
        return {
            "image_url": image_url,
            "groq_advice": advice,
            "gemini_analysis": gemini_desc,
            "sd_prompt": sd_prompt,
            "image_base64": None,
        }
    except Exception as e:
        print(f"❌ Error in /redesign: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
