from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from google import genai
from google.genai import types

from config import settings


router = APIRouter()

client = genai.Client(
    api_key=settings.GEMINI_API_KEY
)


class VisionResponse(BaseModel):
    response: str


@router.post("/analyze", response_model=VisionResponse)
async def analyze_image(
    image: UploadFile = File(...),
    prompt: str = Form("")
):

    if image.content_type not in {
        "image/jpeg",
        "image/png",
        "image/webp"
    }:
        raise HTTPException(
            status_code=400,
            detail="Only JPEG, PNG and WebP images are supported."
        )

    image_bytes = await image.read()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty."
        )

    if not prompt.strip():
        prompt = "Describe this image and explain the important details in it."

    try:
        response = client.models.generate_content(
            model="gemini-3.8-flash",
            contents=[
                types.Part.from_bytes(
                    data=image_bytes,
                    mime_type=image.content_type
                ),
                prompt
            ]
        )

        return VisionResponse(
            response=response.text
        )

    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail=f"Image analysis failed: {str(e)}"
        )
