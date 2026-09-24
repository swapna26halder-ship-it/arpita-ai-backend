

import os
from pathlib import Path

from gtts import gTTS

def text_to_speech(
    text: str,
    lang: str = "en",
    output_file: str = "generated/voice.mp3"
) -> str:
    try:
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        tts = gTTS(
            text=text,
            lang=lang
        )
        tts.save(str(output_path))

        return str(output_path)

    except Exception as error:
        print(f"[TTS ERROR] {error}")
        return ""

def speech_to_text(
    audio_file: str,
    lang: str | None = None
) -> str:
    try:
        audio_path = Path(audio_file)

        if not audio_path.exists():
            return "Audio file not found."

        return f"Speech recognition placeholder for: {audio_path}"

    except Exception as error:
        print(f"[STT ERROR] {error}")
        return ""

def speech_to_speech(
    audio_file: str,
    input_lang: str = "auto",
    output_lang: str = "en"
) -> str:
    try:
        text = speech_to_text(audio_file, lang=None)

        if not text or text.startswith("Audio file not found"):
            return ""

        return text_to_speech(text=text, lang=output_lang)

    except Exception as error:
        print(f"[S2S ERROR] {error}")
        return ""
