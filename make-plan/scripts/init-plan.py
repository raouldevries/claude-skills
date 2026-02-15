#!/usr/bin/env python3
"""
Plan Initializer - Scaffold a new plan file from template.

Usage:
    init-plan.py <title> [--target TARGET] [--path PATH]

Examples:
    init-plan.py "Add User Authentication"
    init-plan.py "Refactor DB Layer" --target "Replace raw SQL with query builder"
    init-plan.py "Fix Login Bug" --path ./docs/plans/
"""

import argparse
import re
import sys
from datetime import date
from pathlib import Path
from typing import Optional

SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE_PATH = SKILL_DIR / "assets" / "plan-template.md"


def to_kebab_case(title: str) -> str:
    """Convert a title to kebab-case filename."""
    # Lowercase, replace non-alphanumeric with hyphens, collapse multiples
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    return slug


def resolve_output_dir(provided_path: Optional[str]) -> Path:
    """Resolve where to write the plan file."""
    if provided_path:
        return Path(provided_path).resolve()

    cwd = Path.cwd()

    # Check for memory-bank/ directory (common in projects)
    memory_bank = cwd / "memory-bank"
    if memory_bank.is_dir():
        plans_dir = memory_bank / "plans"
        plans_dir.mkdir(exist_ok=True)
        return plans_dir

    # Check for .claude/plans/ in project
    claude_plans = cwd / ".claude" / "plans"
    if claude_plans.is_dir():
        return claude_plans

    # Fallback to ~/.claude/plans/
    default_dir = Path.home() / ".claude" / "plans"
    default_dir.mkdir(parents=True, exist_ok=True)
    return default_dir


def main():
    parser = argparse.ArgumentParser(description="Scaffold a new plan file")
    parser.add_argument("title", help="Plan title")
    parser.add_argument("--target", help="Target/goal description", default=None)
    parser.add_argument("--path", help="Output directory", default=None)
    args = parser.parse_args()

    # Read template
    if not TEMPLATE_PATH.exists():
        print(f"Error: Template not found at {TEMPLATE_PATH}", file=sys.stderr)
        sys.exit(1)

    template = TEMPLATE_PATH.read_text()

    # Replace placeholders
    today = date.today().isoformat()
    content = template.replace("# Plan: <!-- TODO: title -->", f"# Plan: {args.title}")
    content = content.replace("<!-- TODO: YYYY-MM-DD -->", today)

    if args.target:
        content = content.replace("<!-- TODO: define target outcome -->", args.target)

    # Resolve output path
    output_dir = resolve_output_dir(args.path)
    filename = f"{to_kebab_case(args.title)}-plan.md"
    output_path = output_dir / filename

    if output_path.exists():
        print(f"Warning: {output_path} already exists, not overwriting", file=sys.stderr)
        sys.exit(1)

    # Write
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content)
    print(f"Created: {output_path}")


if __name__ == "__main__":
    main()
