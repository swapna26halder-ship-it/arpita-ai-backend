

import json
from pathlib import Path

from chat import ask_ai

HISTORY_FILE = Path("generated/study_history.json")
study_history = []


def _build_prompt(title: str, body: str) -> str:
    return f"""
You are an expert {title}.

{body}
""".strip()


def _add_history(entry: dict) -> None:
    study_history.append(entry)
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(study_history, f, ensure_ascii=False, indent=2)


def load_history() -> list:
    if not HISTORY_FILE.exists():
        return []

    with open(HISTORY_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    return data if isinstance(data, list) else []


def clear_history() -> None:
    study_history.clear()
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(study_history, f, ensure_ascii=False, indent=2)


def generate_notes(topic: str) -> str:
    prompt = _build_prompt(
        "study notes generator",
        f"""Create structured study notes on:

{topic}

Requirements:
- Clear explanations
- Important concepts
- Examples
- Exam-focused"""
    )

    _add_history(
        {
            "type": "generate_notes",
            "input": topic,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)


def create_quiz(topic: str) -> str:
    prompt = _build_prompt(
        "quiz creator",
        f"""Create a quiz on:

{topic}

Requirements:
- 10 questions
- Mixed difficulty
- Include answers"""
    )

    _add_history(
        {
            "type": "create_quiz",
            "input": topic,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)


def generate_study_plan(goal: str) -> str:
    prompt = _build_prompt(
        "study plan designer",
        f"""Create a study plan for:

{goal}

Requirements:
- Daily tasks
- Weekly goals
- Revision schedule"""
    )

    _add_history(
        {
            "type": "generate_study_plan",
            "input": goal,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)


def solve_doubt(question: str) -> str:
    prompt = _build_prompt(
        "academic tutor",
        f"""Solve this academic question step by step:

{question}"""
    )

    _add_history(
        {
            "type": "solve_doubt",
            "input": question,
            "prompt": prompt
        }
    )

    return ask_ai(prompt)
