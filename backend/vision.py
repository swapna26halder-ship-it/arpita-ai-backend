from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from google import genai
from google.genai import types

from config import settings


router = APIRouter()

VISION_MODEL = "gemini-3.8-flash"

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}


class VisionResponse(BaseModel):
    response: str


@router.post("/analyze", response_model=VisionResponse)
def analyze_image(
    image: UploadFile = File(...),
    prompt: str = Form("")
):

    if not settings.GEMINI_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="Gemini API key is not configured."
        )

    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Only JPEG, PNG and WebP images are supported."
        )

    image_bytes = image.file.read()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty."
        )

    if len(image_bytes) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="Image too large (max 10MB)."
        )

    question = prompt.strip() or (
        "Describe this image and explain the important details in it."
    )

    try:
        client = genai.Client(api_key=settings.GEMINI_API_KEY)

        result = client.models.generate_content(
            model=VISION_MODEL,
            contents=[
                types.Part.from_bytes(
                    data=image_bytes,
                    mime_type=image.content_type
                ),
                question
            ]
        )

        text = (result.text or "").strip()

        if not text:
            raise HTTPException(
                status_code=502,
                detail="Gemini returned an empty response."
            )

        return VisionResponse(response=text)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail=f"Image analysis failed: {str(e)}"
        )