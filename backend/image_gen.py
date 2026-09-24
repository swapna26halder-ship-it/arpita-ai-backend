
from fastapi import APIRouter
import urllib.parse
from pydantic import BaseModel, HttpUrl

router = APIRouter()

def generate_image_url(
    prompt: str,
    width: int = 1024,
    height: int = 1024
) -> str:
    encoded_prompt = urllib.parse.quote(prompt)

    image_url = (
        f"https://image.pollinations.ai/promot/"
        f"{encoded_prompt}"
        f"?width={width}"
        f"&height={height}"
    )

    return image_url


class ImageRequest(BaseModel):
    prompt: str

class ImageResponse(BaseModel):
    image_url: HttpUrl

@router.post("/generate", response_model=ImageResponse)
async def generate_image(request: ImageRequest):
    image_url = generate_image_url(request.prompt)
    return ImageResponse(image_url=image_url)

