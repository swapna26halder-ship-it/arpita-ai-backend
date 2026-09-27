from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from config import settings
import requests
import uuid
from pathlib import Path


router = APIRouter()


# Edited images will be stored in the generated folder
EDITED_DIR = Path(settings.GENERATED_DIR)
EDITED_DIR.mkdir(parents=True, exist_ok=True)


class ImageEditResponse(BaseModel):
    image_url: str


@router.post("/edit", response_model=ImageEditResponse)
async def edit_image(
    image: UploadFile = File(...),
    prompt: str = Form(...)
):

    prompt = prompt.strip()

    if not prompt:
        raise HTTPException(
            status_code=400,
            detail="Edit prompt cannot be empty."
        )

    if image.content_type not in {
        "image/jpeg",
        "image/png",
        "image/webp"
    }:
        raise HTTPException(
            status_code=400,
            detail="Only JPEG, PNG and WebP images are supported."
        )

    api_key = settings.POLLINATIONS_API_KEY

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Pollinations API key is not configured."
        )

    image_bytes = await image.read()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty."
        )

    # Pollinations image editing endpoint
    url = "https://gen.pollinations.ai/v1/images/edits"

    headers = {
        "Authorization": f"Bearer {api_key}"
    }

    files = {
        "image": (
            image.filename or "image.png",
            image_bytes,
            image.content_type
        )
    }

    data = {
        "prompt": prompt,
        "model": "gptimage"
    }

    try:
        response = requests.post(
            url,
            headers=headers,
            files=files,
            data=data,
            timeout=180
        )

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Pollinations editing failed: {response.text}"
            )

        result = response.json()

        # OpenAI-style image response
        if not result.get("data"):
            raise HTTPException(
                status_code=502,
                detail="No edited image was returned."
            )

        image_data = result["data"][0]

        # Handle base64 response
        if "b64_json" in image_data:
            import base64

            edited_bytes = base64.b64decode(
                image_data["b64_json"]
            )

            filename = f"{uuid.uuid4().hex}.png"
            file_path = EDITED_DIR / filename

            file_path.write_bytes(edited_bytes)

            image_url = f"/image/generated/{filename}"

            return ImageEditResponse(
                image_url=image_url
            )

        # Handle URL response if provider returns one
        if "url" in image_data:
            return ImageEditResponse(
                image_url=image_data["url"]
            )

        raise HTTPException(
            status_code=502,
            detail="Pollinations returned an unsupported image response."
        )

    except requests.RequestException as e:
        raise HTTPException(
            status_code=502,
            detail=f"Image editing request failed: {str(e)}"
        )
