from groq import Groq
from google import genai

from config import settings

# =========================
# CLIENTS
# =========================

groq_client = Groq(
    api_key=settings.GROQ_API_KEY
)

gemini_client = genai.Client(
    api_key=settings.GEMINI_API_KEY
)

# =========================
# MODELS
# =========================

GROQ_MODEL = "qwen/qwen3.6-27b"
GEMINI_MODEL = "gemini-2.5-flash"

# =========================
# SYSTEM PROMPT
# =========================

SYSTEM_PROMPT = """
You are Arpita AI, made by Arpita Halder.

Identity:

- Advanced AI Assistant
- AI Tutor
- Research Assistant
- Coding Assistant
- Content Creator
- Generative AI

Behavior:

- Be helpful and professional.
- Explain step by step.
- Adapt to the user's level.
- Give practical examples.
- Be concise when appropriate.
- Be detailed when needed.
- Be friendly and funny.
- Emotions as user.
- Give emoji in chat more and more.

Rules:

1. Never invent facts.
2. State uncertainty when uncertain.
3. Prioritize accuracy over confidence.
4. Use clear and structured answers.
5. Respect conversation context.
"""

# =========================
# SIMPLE MEMORY (Phase 1)
# =========================

conversation_memory = []

# =========================
# GROQ CHAT
# =========================

def ask_groq(prompt: str, history : list = None) -> str:
    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        }
    ]
    if history :
        for item in conversation_memory[-70:]:
            messages.append(item)

    messages.append(
        {
            "role": "user",
            "content": prompt,
        }
    )

    response = groq_client.chat.completions.create(
        model=GROQ_MODEL,
        messages=messages,
        temperature=0.7,
        max_tokens=2048,
    )

    reply = response.choices[0].message.content

    conversation_memory.append(
        {
            "role": "user",
            "content": prompt,
        }
    )

    conversation_memory.append(
        {
            "role": "assistant",
            "content": reply,
        }
    )

    return reply

# =========================
# GEMINI FALLBACK
# =========================

def ask_gemini(prompt: str) -> str:
    response = gemini_client.models.generate_content(
        model=GEMINI_MODEL,
        contents=prompt,
        config= {
            "system_instruction":SYSTEM_PROMPT
            }
    )
    return response.text

# =========================
# MAIN AI ENGINE
# =========================

def ask_ai(prompt: str) -> str:
    try:
        return ask_groq(prompt)

    except Exception as groq_error:
        print(f"[GROQ ERROR] {groq_error}")
        print("[INFO] Switching to Gemini fallback...")

        try:
            return ask_gemini(prompt)

        except Exception as gemini_error:
            print(f"[GEMINI ERROR] {gemini_error}")
            return "Arpita AI is temporarily unavailable for any issue like internet disconnection or others . " \
            "Please try again ."
