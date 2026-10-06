from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from io import BytesIO
from pathlib import Path
import base64
import re
import uuid

import requests
from PIL import Image, UnidentifiedImageError

from config import settings


router = APIRouter()

GENERATED_DIR = Path(settings.GENERATED_DIR)
GENERATED_DIR.mkdir(parents=True, exist_ok=True)

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}

# Pollinations docs-এর edit example-এ এই model আছে
EDIT_MODEL = "kontext"

ID_PATTERN = re.compile(r"^[A-Za-z0-9_-]{1,64}$")

# PIL format -> (mime type, file extension)
FORMAT_INFO = {
    "JPEG": ("image/jpeg", "jpg"),
    "PNG": ("image/png", "png"),
    "WEBP": ("image/webp", "webp"),
}


class ImageEditResponse(BaseModel):
    image_url: str
    installationId: str = ""
    chatId: str = ""
    messageId: str = ""


def clean_id(value: str, field_name: str, default: str = "") -> str:
    value = (value or "").strip()
    if not value:
        return default
    if not ID_PATTERN.match(value):
        raise HTTPException(
            status_code=400,
            detail=f"Invalid {field_name}."
        )
    return value


def inspect_image(data: bytes):
    """Valid image কিনা দেখে, (mime, extension) return করে।"""
    try:
        img = Image.open(BytesIO(data))
        fmt = img.format
        img.verify()
    except (UnidentifiedImageError, OSError, SyntaxError, ValueError):
        return None
    return FORMAT_INFO.get(fmt)


@router.post("/edit", response_model=ImageEditResponse)
def edit_image(
    image: UploadFile = File(...),
    prompt: str = Form(...),
    installationId: str = Form(""),
    chatId: str = Form(""),
    messageId: str = Form(""),
):

    prompt = prompt.strip()

    if not prompt:
        raise HTTPException(
            status_code=400,
            detail="Edit prompt cannot be empty."
        )

    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Only JPEG, PNG and WebP images are supported."
        )

    installation_id = clean_id(installationId, "installationId", "anonymous")
    chat_id = clean_id(chatId, "chatId", "no-chat")
    message_id = clean_id(messageId, "messageId", "")

    api_key = settings.POLLINATIONS_API_KEY

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Pollinations API key is not configured."
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

    # আসল image কিনা যাচাই করা + আসল format থেকে MIME type নেওয়া
    info = inspect_image(image_bytes)

    if info is None:
        raise HTTPException(
            status_code=400,
            detail="Uploaded file is not a valid image."
        )

    real_mime, _ = info

    url = "https://gen.pollinations.ai/v1/images/edits"
    headers = {"Authorization": f"Bearer {api_key}"}

    files = {
        "image": (
            image.filename or "image",
            image_bytes,
            real_mime
        )
    }

    data = {
        "prompt": prompt,
        "model": EDIT_MODEL,
        "response_format": "b64_json",
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
                detail=f"Pollinations editing failed: {response.text[:300]}"
            )

        try:
            result = response.json()
        except ValueError:
            raise HTTPException(
                status_code=502,
                detail="Pollinations returned an invalid response."
            )

        if not result.get("data"):
            raise HTTPException(
                status_code=502,
                detail="No edited image was returned."
            )

        image_data = result["data"][0]

        if image_data.get("b64_json"):
            try:
                edited_bytes = base64.b64decode(image_data["b64_json"])
            except ValueError:
                raise HTTPException(
                    status_code=502,
                    detail="Edited image data was corrupted."
                )

        elif image_data.get("url"):
            img_resp = requests.get(image_data["url"], timeout=60)
            if img_resp.status_code != 200:
                raise HTTPException(
                    status_code=502,
                    detail="Failed to download edited image."
                )
            edited_bytes = img_resp.content

        else:
            raise HTTPException(
                status_code=502,
                detail="Pollinations returned an unsupported image response."
            )

    except requests.RequestException as e:
        raise HTTPException(
            status_code=502,
            detail=f"Image editing request failed: {str(e)}"
        )

    # Result সত্যিই image কিনা দেখে সঠিক extension বসানো
    out_info = inspect_image(edited_bytes)

    if out_info is None:
        raise HTTPException(
            status_code=502,
            detail="Pollinations did not return a valid image."
        )

    _, ext = out_info

    # generated/<installationId>/<chatId>/ এর ভেতরে save হবে
    save_dir = GENERATED_DIR / installation_id / chat_id
    save_dir.mkdir(parents=True, exist_ok=True)

    name = uuid.uuid4().hex
    filename = f"{message_id}_{name}.{ext}" if message_id else f"{name}.{ext}"

    (save_dir / filename).write_bytes(edited_bytes)

    return ImageEditResponse(
        image_url=f"/image/generated/{installation_id}/{chat_id}/{filename}",
        installationId=installation_id,
        chatId=chat_id,
        messageId=message_id,
    )