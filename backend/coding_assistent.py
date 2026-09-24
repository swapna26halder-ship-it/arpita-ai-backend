import json
from pathlib import Path

from chat import ask_ai

HISTORY_FILE = Path("generated/code_history.json")
code_history = []


def _build_prompt(title: str, body: str) -> str:
    return f"""
You are an expert {title}.

{body}
""".strip()


def _add_history(entry: dict) -> None:
    code_history.append(entry)
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(code_history, f, ensure_ascii=False, indent=2)


def load_history() -> list:
    if not HISTORY_FILE.exists():
        return []

    with open(HISTORY_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    return data if isinstance(data, list) else []


def clear_history() -> None:
    code_history.clear()
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(code_history, f, ensure_ascii=False, indent=2)


def generate_code(task: str) -> str:
    prompt = _build_prompt(
        "software engineer",
        f"""Task:
{task}

Generate production-quality code.

Requirements:
- Follow best practices
- Include explanations
- Write clean code
- Avoid unnecessary complexity"""
    )

    _add_history(
        {
            "type": "generate_code",
            "input": task,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)


def debug_code(error_message: str) -> str:
    prompt = _build_prompt(
        "debugging assistant",
        f"""Analyze the following error:

{error_message}

Provide:
1. Root cause
2. Fix
3. Prevention"""
    )

    _add_history(
        {
            "type": "debug_code",
            "input": error_message,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)


def explain_code(code: str) -> str:
    prompt = _build_prompt(
        "code explainer",
        f"""Explain this code step by step:

{code}"""
    )

    _add_history(
        {
            "type": "explain_code",
            "input": code,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)
