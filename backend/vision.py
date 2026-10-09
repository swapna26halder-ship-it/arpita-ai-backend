import time

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from google import genai
from google.genai import types

from config import settings


router = APIRouter()

# প্রথমটা ব্যস্ত থাকলে পরেরটা চেষ্টা করবে
VISION_MODELS = [
    "gemini-3.8-flash",
    "gemini-3.7-flash",
    "gemini-2.5-flash",
]

ATTEMPTS_PER_MODEL = 2
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}


class VisionResponse(BaseModel):
    response: str


def is_busy_error(error: Exception) -> bool:
    text = str(error)
    return "503" in text or "UNAVAILABLE" in text or "429" in text


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

    client = genai.Client(api_key=settings.GEMINI_API_KEY)

    contents = [
        types.Part.from_bytes(
            data=image_bytes,
            mime_type=image.content_type
        ),
        question
    ]

    last_error = None

    for model_name in VISION_MODELS:
        for attempt in range(ATTEMPTS_PER_MODEL):
            try:
                result = client.models.generate_content(
                    model=model_name,
                    contents=contents
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
                last_error = e

                if not is_busy_error(e):
                    raise HTTPException(
                        status_code=502,
                        detail=f"Image analysis failed: {str(e)}"
                    )

                time.sleep(2)

    raise HTTPException(
        status_code=503,
        detail=(
            "The image analysis service is busy right now. "
            f"Please try again in a minute. ({str(last_error)[:200]})"
        )
    )
