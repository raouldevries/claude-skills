"""Tests for init-plan.py's filename slugification.

Run from anywhere:
    pytest ~/.claude/skills/make-plan/scripts/test_init_plan.py
"""

import importlib.util
from datetime import date
from pathlib import Path

# init-plan.py is not importable by name (hyphen), so load it from its path.
_SPEC = importlib.util.spec_from_file_location(
    "init_plan", Path(__file__).resolve().parent / "init-plan.py"
)
init_plan = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(init_plan)
to_kebab_case = init_plan.to_kebab_case


def test_plain_ascii_title():
    assert to_kebab_case("Add User Authentication") == "add-user-authentication"


def test_collapses_and_trims_separators():
    assert to_kebab_case("  Fix   Login!! Bug  ") == "fix-login-bug"


def test_accented_latin_is_transliterated_not_dropped():
    # Was previously mangled to "caf-fa-ade-ni-o".
    assert to_kebab_case("Café Façade Niño") == "cafe-facade-nino"


def test_accents_do_not_collapse_to_empty():
    slug = to_kebab_case("Évaluation Privée")
    assert slug == "evaluation-privee"
    assert slug  # never empty


def test_punctuation_only_title_gets_dated_fallback():
    slug = to_kebab_case("!!!")
    assert slug.startswith(f"plan-{date.today().isoformat()}-")
    assert slug != "-"  # not the old degenerate bare stem


def test_cjk_only_title_gets_nonempty_slug():
    slug = to_kebab_case("日本語")
    assert slug.startswith(f"plan-{date.today().isoformat()}-")
    assert len(slug) > len(f"plan-{date.today().isoformat()}-")


def test_distinct_untranslatable_titles_do_not_collide():
    # Two different non-Latin titles on the same day must differ
    # (the content hash guarantees this), so the no-overwrite guard
    # in main() does not silently fail the second scaffold call.
    a = to_kebab_case("日本語")
    b = to_kebab_case("中文")
    assert a != b


def test_fallback_is_deterministic():
    assert to_kebab_case("日本語") == to_kebab_case("日本語")
