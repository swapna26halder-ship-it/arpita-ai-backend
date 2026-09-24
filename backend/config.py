
from dotenv import load_dotenv
import os

# Load .env file
load_dotenv()

class Settings:
    APP_NAME = "Arpita AI"
    APP_VERSION = "1.0.0"

    # API Keys
    GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

    # Database
    DATABASE_URL = os.getenv(
        "DATABASE_URL",
        "sqlite:///database/arpita_ai.db"
    )

    #Security
    SECRET_KEY= os.getenv(
        "",

        "change-this-to-a-long-random-secret-key"
    ) 

    # Upload Paths
    UPLOAD_DIR = "uploads"
    GENERATED_DIR = "generated"
    LOG_DIR = "logs"

settings = Settings()

# Validation
if not settings.GROQ_API_KEY:
    print("⚠️ GROQ_API_KEY not found in .env")
