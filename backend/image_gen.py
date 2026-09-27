from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, HttpUrl
from pathlib import Path
import requests
import uuid

from config import settings


router = APIRouter()


# Generated image storage
GENERATED_DIR = Path(settings.GENERATED_DIR)
GENERATED_DIR.mkdir(parents=True, exist_ok=True)


class ImageRequest(BaseModel):
    prompt: str


class ImageResponse(BaseModel):
    image_url: HttpUrl


@router.post("/generate", response_model=ImageResponse)
async def generate_image(request: ImageRequest):

    prompt = request.prompt.strip()

    if not prompt:
        raise HTTPException(
            status_code=400,
            detail="Prompt cannot be empty."
        )

    # API key comes indirectly from .env through config.py
    api_key = settings.POLLINATIONS_API_KEY

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Pollinations API key is not configured."
        )

    # Pollinations image endpoint
    url = "https://gen.pollinations.ai/image/" + requests.utils.quote(prompt)

    params = {
        "model": "flux",
        "width": 1024,
        "height": 1024,
    }

    headers = {
        "Authorization": f"Bearer {api_key}"
    }

    try:
        response = requests.get(
            url,
            params=params,
            headers=headers,
            timeout=120
        )

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail="Pollinations image generation failed."
            )

        # Unique filename
        filename = f"{uuid.uuid4().hex}.png"
        file_path = GENERATED_DIR / filename

        # Save image on YOUR backend
        file_path.write_bytes(response.content)

    except requests.RequestException as e:
        raise HTTPException(
            status_code=502,
            detail=f"Image generation request failed: {str(e)}"
        )

    # Android receives YOUR backend URL,
    # not the Pollinations URL or API key.
    image_url = f"/image/generated/{filename}"

    return ImageResponse(
        image_url=image_url
    )
