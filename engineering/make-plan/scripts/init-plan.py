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
import hashlib
import json
import re
import sys
import unicodedata
from datetime import date
from pathlib import Path
from typing import Optional

SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE_PATH = SKILL_DIR / "assets" / "plan-template.md"

# Conventions recognized when no pin and no --path are given, in priority
# order. We HONOR whichever already exists in the repo rather than inventing
# a new one — this is what stops plans from scattering across folders.
KNOWN_CONVENTIONS = ("plans", ".claude/plans", "memory-bank/plans")
DEFAULT_CONVENTION = ".claude/plans"
CONFIG_REL = ".claude/make-plan.json"


def to_kebab_case(title: str) -> str:
    """Convert a title to a kebab-case filename stem.

    Non-ASCII letters are transliterated to their closest ASCII form
    (cafe -> cafe, niño -> nino) so accented or non-Latin titles do not
    collapse to empty or colliding slugs. If nothing usable remains
    (punctuation-only or fully non-transliterable input), fall back to a
    date-stamped stem so the result is never a bare "-plan.md".
    """
    # Decompose accents, drop non-ASCII, then slugify.
    ascii_title = (
        unicodedata.normalize("NFKD", title)
        .encode("ascii", "ignore")
        .decode("ascii")
    )
    slug = re.sub(r"[^a-z0-9]+", "-", ascii_title.lower()).strip("-")
    if not slug:
        # Nothing transliterable remained (e.g. punctuation-only or CJK-only
        # titles). Date-stamp and append a short content hash so two distinct
        # untranslatable titles created on the same day still differ.
        digest = hashlib.sha1(title.encode("utf-8")).hexdigest()[:8]
        slug = f"plan-{date.today().isoformat()}-{digest}"
    return slug


def find_repo_root(start: Path) -> Path:
    """Walk up from `start` to the enclosing git repo root.

    Resolution is anchored to the repo root, not the current working
    directory, so running the script from a subdirectory of a monorepo
    still writes the plan to the project's single plans folder instead of
    spawning a nested copy (e.g. apps/api/memory-bank/plans/). Falls back
    to `start` when no .git is found.
    """
    start = start.resolve()
    for parent in (start, *start.parents):
        if (parent / ".git").exists():
            return parent
    return start


def pinned_dir(root: Path) -> Optional[Path]:
    """Return the per-project pinned plans dir, or None.

    A repo opts out of auto-detection by committing
    `.claude/make-plan.json` with {"plans_dir": "<relative path>"}.
    Malformed JSON, a missing/blank key, or a non-string value is treated
    as "no pin" so a broken config never crashes scaffolding.
    """
    cfg = root / CONFIG_REL
    if not cfg.is_file():
        return None
    try:
        pinned = json.loads(cfg.read_text()).get("plans_dir")
    except (json.JSONDecodeError, OSError, ValueError, AttributeError):
        return None
    if not isinstance(pinned, str) or not pinned.strip():
        return None
    return root / pinned.strip()


def resolve_output_dir(provided_path: Optional[str]) -> Path:
    """Resolve where to write the plan file.

    Precedence (first match wins), all anchored to the git repo root:
      1. --path on the command line (explicit; absolute or cwd-relative)
      2. a per-project pin in .claude/make-plan.json ("plans_dir")
      3. an existing convention dir already in the repo (honor, don't invent)
      4. a single default (.claude/plans/) at the repo root

    Resolution is side-effect-free: the caller (main) creates the chosen
    directory at write time, so merely resolving never spawns a folder.
    """
    if provided_path:
        return Path(provided_path).resolve()

    root = find_repo_root(Path.cwd())

    pinned = pinned_dir(root)
    if pinned is not None:
        return pinned

    for convention in KNOWN_CONVENTIONS:
        candidate = root / convention
        if candidate.is_dir():
            return candidate

    return root / DEFAULT_CONVENTION


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
