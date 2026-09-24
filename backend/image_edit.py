from io import BytesIO
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status
from pydantic import BaseModel
from PIL import Image, UnidentifiedImageError

from pathlib import Path

router = APIRouter()


class ImageEditResponse(BaseModel):
    filename: str
    content_type: str
    prompt: str
    message: str


ALLOWED_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
}

MAX_FILE_SIZE = 10 * 1024 * 1024 # 10 MB


@router.post("/edit", response_model=ImageEditResponse)
async def edit_image(
    image: UploadFile = File(...),
    prompt: str = Form(...)
):
    prompt = prompt.strip()
    if not prompt:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Prompt cannot be empty."
        )

    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Only JPG, PNG and WEBP images are allowed."
        )

    contents = await image.read()

    if not contents:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is empty."
        )

    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image size must be under 10 MB."
        )

    try:
        img = Image.open(BytesIO(contents))
        img.verify()
    except (UnidentifiedImageError, OSError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is not a valid image."
        )

    await image.seek(0)

    # TODO: Call your AI image editing model here using `contents` and `prompt`

    return ImageEditResponse(
        filename=image.filename or "uploaded_image",
        content_type=image.content_type or "application/octet-stream",
        prompt=prompt,
        message="Image received successfully. Ready for AI editing."
    )

