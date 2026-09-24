

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from database import engine
from models import Base
from chat import ask_ai
from auth import router as auth_router


from image_gen import router as image_gen_router
from image_edit import router as image_edit_router
from vision import router as vision_router





Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Arpita AI",
    description="Personal AI Assistant",
    version="1.0.0"
)

app.include_router(
    auth_router)

app.include_router(
    image_gen_router,
    prefix="/image",
    tags=["Image Generation"]
)

app.include_router(
    image_edit_router,
    prefix="/image",
    tags=["Image Editing"]
)

app.include_router(
    vision_router,
    prefix="/vision",
    tags=["Vision"]
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

@app.get("/")
async def root():
    return {
        "app": "Arpita AI",
        "status": "online",
        "version": "1.0.0"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy"
    }

@app.post("/chat")
async def chat(request: ChatRequest):
    reply = ask_ai(request.message)
    return {
        "response": reply
    }

@app.post("/analyze")
def analyze_image():
    return {
        "status": "success",
        "message": "Vision Analysis endpoint is working."
    }

@app.post("/edit")
def edit_image():
    return {
        "status": "success",
        "message": "Image Editing endpoint is working."
    }


@app.post("/generate")
def generate_image():
    return {
        "status": "success",
        "message": "Image Generation endpoint is working."
    }

@app.get("/features")
async def features():
    return {
        "chat": True,
        "memory": True,
        "vision": True,
        "voice": True,
        "image_generation": True,
        "image_editing": True,
        "coding_assistant": True,
        "study_helper": True
    }

# Future Routes
# /voice
# /vision
# /image-gen
# /image-edit
# /content-creator
# /music
# /video
# /auth
# /RAG
