"""
Quick integration test for the /predict endpoint.
Creates a dummy 224x224 JPEG and POSTs it to the running FastAPI server.
"""
import io, requests
from PIL import Image

# Create a dummy green fabric image
img = Image.new("RGB", (224, 224), color=(80, 140, 80))
buf = io.BytesIO()
img.save(buf, format="JPEG")
buf.seek(0)

try:
    response = requests.post(
        "http://127.0.0.1:8000/predict",
        files={"image": ("test.jpg", buf, "image/jpeg")},
        timeout=30,
    )
    print("Status:", response.status_code)
    print("Response:", response.json())
except Exception as e:
    print("ERROR:", e)
    print("Make sure the server is running: uvicorn main:app --reload")
