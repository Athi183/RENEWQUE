from fastapi import FastAPI

app = FastAPI(title="RenewQue AI Backend")

@app.get("/")
def health_check():
    return {"status": "RenewQue backend running 🚀"}
