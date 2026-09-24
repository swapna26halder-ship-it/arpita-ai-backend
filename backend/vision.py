from fastapi import APIRouter,UploadFile, File, Form, HTTPException, status
from pydantic import BaseModel

from pathlib import Path

from google import genai
from PIL import Image

from config import settings

router = APIRouter()

client = genai.Client(
    api_key=settings.GEMINI_API_KEY
)

VISION_MODEL = "gemini-2.5-flash"


    
    
class VisionResponse(BaseModel):
    filename: str
    content_type: str
    prompt: str
    message: str


ALLOWED_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
}


@router.post("/analyze", response_model=VisionResponse)
async def analyze_image(
    image: UploadFile = File(...),
    prompt: str = Form("")
):
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Only JPG, PNG and WEBP images are allowed."
        )

    return VisionResponse(
        filename=image.filename or "uploaded_image",
        content_type=image.content_type or "application/octet-stream",
        prompt=prompt.strip(),
        message="Image received successfully. Ready for AI vision analysis."
    )

