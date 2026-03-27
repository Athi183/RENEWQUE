from fastapi import FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import os
import requests
import base64
import urllib.parse
from urllib.parse import quote
from dotenv import load_dotenv
import google.generativeai as genai
from groq import Groq

# ── Optional: new google-genai SDK (for image generation) ──
try:
    from google import genai as google_genai_new
    from google.genai import types as genai_types
    NEW_GENAI_AVAILABLE = True
except ImportError:
    NEW_GENAI_AVAILABLE = False

# ── Optional: torch (only needed for /predict similarity search) ──
try:
    import torch
    import torch.nn.functional as F
    from torchvision import models, transforms
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GROQ_API_KEY   = os.getenv("GROQ_API", "")
HF_TOKEN       = os.getenv("HF_TOKEN", "")

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

os.makedirs(os.path.join(BASE_DIR, "outputs"), exist_ok=True)


def _build_image_index():
    """Build a filename -> absolute path lookup for serving recommendation previews."""
    candidate_dirs = []
    env_dir = os.getenv("IMAGE_DATASET_DIR", "").strip()
    if env_dir:
        candidate_dirs.append(env_dir)
    candidate_dirs.extend(
        [
            os.path.join(BASE_DIR, "images"),
            os.path.join(BASE_DIR, "dataset"),
            os.path.join(BASE_DIR, "outputs"),
        ]
    )

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

# ── Load embeddings + EfficientNet model (only if torch is available) ──
embeddings      = None
image_names     = []
embedding_vectors = None
image_index     = _build_image_index()
model           = None
transform       = None

if TORCH_AVAILABLE:
    try:
        _emb_path = os.path.join(BASE_DIR, "fashion_embeddings.pth")
        if os.path.exists(_emb_path):
            embeddings        = torch.load(_emb_path)
            image_names       = list(embeddings.keys())
            embedding_vectors = torch.stack(list(embeddings.values()))
        _m = models.efficientnet_b0(pretrained=True)
        model = torch.nn.Sequential(
            _m.features,
            torch.nn.AdaptiveAvgPool2d(1),
            torch.nn.Flatten()
        )
        model.eval()
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406],
                                 [0.229, 0.224, 0.225])
        ])
        print("✅ Torch model loaded — /predict is available")
    except Exception as e:
        print(f"⚠️  Torch model load failed: {e} — /predict will be unavailable")
else:
    print("ℹ️  torch not installed — /predict unavailable, /redesign works fine")


@app.post("/predict")
async def predict(request: Request, file: UploadFile = File(...)):
    if not TORCH_AVAILABLE or model is None or embedding_vectors is None:
        raise HTTPException(
            status_code=503,
            detail="Similarity search unavailable (torch not installed). Use /redesign instead."
        )
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    image = transform(image).unsqueeze(0)

    with torch.no_grad():
        query_embedding = model(image)

    similarities = F.cosine_similarity(
        query_embedding,
        embedding_vectors
    )

    top_indices = similarities.topk(5).indices

    results = []
    for idx in top_indices:
        image_name = image_names[idx]
        image_url = None
        if image_name in image_index:
            image_url = f"{request.base_url}images/{quote(image_name)}"
        results.append({
            "name": image_name,
            "score": float(similarities[idx]),
            "image_url": image_url,
        })

    return {"similar_images": results}


@app.get("/images/{image_name:path}")
async def get_image(image_name: str):
    filename = os.path.basename(image_name)
    image_path = image_index.get(filename)
    if not image_path or not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Image not found")
    return FileResponse(image_path)


# ─────────────────────────────────────────────
# Helper: Step 1 – Gemini Vision analysis
# ─────────────────────────────────────────────
def analyze_image_with_gemini(image_bytes: bytes) -> str:
    """Send clothing image to Gemini Vision and get a structured description."""
    # Try models in order — gemini-2.0-flash is the current default
    potential_models = [
        "gemini-2.0-flash",
        "gemini-2.0-flash-lite",
        "gemini-1.5-flash",
        "gemini-1.5-pro",
    ]
    last_error = None
    # 1. Try known stable models first
    for model_name in potential_models:
        try:
            print(f"🤖 Trying Gemini model: {model_name}...")
            model = genai.GenerativeModel(model_name)
            img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            response = model.generate_content([
                img,
                (
                    "You are a high-end luxury fashion consultant. Analyze this garment with extreme precision. "
                    "Provide a 'Hyper-Description' covering:\n"
                    "1. GARMENT DNA: Exact type, fit, and silhouette.\n"
                    "2. MATERIAL & TEXTURE: Be specific (e.g., ribbed georgette, slubby linen).\n"
                    "3. COLOR PALETTE: Identify primary and secondary shades.\n"
                    "4. HARDWARE & DETAILS: Mention buttons, trim, stitching.\n"
                    "Return only this detailed structural analysis in 2-3 concise paragraphs."
                )
            ])
            return response.text.strip()
        except Exception as e:
            print(f"⚠️ {model_name} failed: {e}")
            last_error = e
            continue

    # 2. Smart Discovery: Find ANY working model if the above fail
    try:
        available = [m.name.replace("models/", "") for m in genai.list_models() 
                     if 'generateContent' in m.supported_generation_methods]
        
        # Prioritize 'flash' models in the discovered list
        discovered = sorted(available, key=lambda x: 'flash' not in x.lower())
        
        for model_name in discovered:
            if model_name in potential_models: continue
            try:
                print(f"🚀 Trying discovered model: {model_name}")
                model = genai.GenerativeModel(model_name)
                response = model.generate_content([
                    Image.open(io.BytesIO(image_bytes)).convert("RGB"),
                    "Describe this garment simply including material and color."
                ])
                return response.text.strip()
            except:
                continue
    except:
        pass

    if last_error:
        raise last_error
    return "a stylish garment"


# ─────────────────────────────────────────────
# Helper: Step 2 – Groq prompt generation
# ─────────────────────────────────────────────
def build_sd_prompt_with_groq(gemini_description: str, user_idea: str) -> str:
    """Use Groq to turn the visual description + user idea into a Stable Diffusion prompt."""
    if not groq_client:
        # Fallback: simple concatenation
        return (
            f"a redesigned {gemini_description} based on {user_idea}, "
            "displayed on a professional fashion mannequin, "
            "fashion photography, studio lighting, high detail"
        )

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
        messages=[
            {"role": "system", "content": system_msg},
            {
                "role": "user",
                "content": (
                    f"Original garment: {gemini_description}\n"
                    f"Redesign idea: {user_idea}"
                ),
            },
        ],
        max_tokens=200,
        temperature=0.7,
    )
    return chat.choices[0].message.content.strip()


# ─────────────────────────────────────────────
# Helper: Step 3 – Image Generation (Pollinations Flux)
# ─────────────────────────────────────────────
def generate_image_url_pollinations(prompt: str) -> str:
    """
    Build a Pollinations.ai URL using their new authenticated API.
    Uses a public publishable key for free instant generation.
    """
    clean_prompt = prompt.strip().replace('"', '')[:250]
    encoded = urllib.parse.quote(clean_prompt)
    
    # Using the public key found for the Pollinations demo
    public_key = "pk_31oNBvU9JLA1ApNX"
    
    # NEW gen.pollinations.ai endpoint
    url = (
        f"https://gen.pollinations.ai/image/{encoded}"
        f"?model=flux&width=512&height=768&nologo=true&key={public_key}"
    )
    print(f"🌐 Pollinations URL: {url[:80]}...")
    return url


# ─────────────────────────────────────────────
# Helper: Groq fashion advice
# ─────────────────────────────────────────────
def get_groq_advice(gemini_description: str, user_idea: str) -> str:
    """Generate friendly fashion redesign advice from Groq."""
    if not groq_client:
        return "Here is your redesigned outfit based on your idea!"

    system_msg = (
        "You are RenewQue, a sustainable fashion redesign assistant. "
        "Given a garment description and the user's redesign idea, "
        "give 2-3 sentences of friendly, practical redesign advice. "
        "Mention materials, sustainability tips, and styling suggestions. "
        "Keep it concise."
    )
    chat = groq_client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[
            {"role": "system", "content": system_msg},
            {
                "role": "user",
                "content": (
                    f"Garment: {gemini_description}\n"
                    f"Redesign idea: {user_idea}"
                ),
            },
        ],
        max_tokens=180,
        temperature=0.7,
    )
    return chat.choices[0].message.content.strip()


# ─────────────────────────────────────────────
# NEW ENDPOINT: /redesign
# ─────────────────────────────────────────────
@app.post("/redesign")
async def redesign(
    file: UploadFile = File(...),
    prompt: str = Form(default="redesign this outfit in a modern style"),
):
    """
    Full pipeline:
      1. Gemini Vision  → extract garment features from image
      2. Groq           → build Stable Diffusion prompt + generate advice
      3. Pollinations   → return generated image URL (no local GPU)
    """
    print(f"📥 Received redesign request: prompt='{prompt}'")
    try:
        image_bytes = await file.read()
        print(f"📸 Image read successfully: {len(image_bytes)} bytes")

        # Step 1: Gemini Vision analysis
        print("🤖 Analyzing with Gemini Vision...")
        gemini_desc = analyze_image_with_gemini(image_bytes)
        print(f"📝 Gemini description: {gemini_desc}")

        # Step 2a: Build rich SD prompt via Groq
        print("🔧 Building SD prompt with Groq...")
        sd_prompt = build_sd_prompt_with_groq(gemini_desc, prompt)
        print(f"🎨 SD prompt: {sd_prompt}")

        # Step 2b: Get friendly advice from Groq
        print("💡 Getting fashion advice from Groq...")
        advice = get_groq_advice(gemini_desc, prompt)

        # Step 3: Generate image URL with Pollinations (Flux model)
        print("🎨 Generating image with Pollinations Flux...")
        image_url = generate_image_url_pollinations(sd_prompt)

        print("✅ Redesign completed successfully")
        return {
            "image_url":        image_url,
            "image_base64":     None,
            "groq_advice":      advice,
            "gemini_analysis":  gemini_desc,
            "sd_prompt":        sd_prompt,
        }

    except Exception as e:
        print(f"❌ Error in /redesign: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
