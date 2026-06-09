"""Tests for init-plan.py: filename slugification and output-dir resolution.

Run from the scripts/ directory (or anywhere):
    pytest test_init_plan.py
"""

import importlib.util
import json
from datetime import date
from pathlib import Path

# init-plan.py is not importable by name (hyphen), so load it from its path.
_SPEC = importlib.util.spec_from_file_location(
    "init_plan", Path(__file__).resolve().parent / "init-plan.py"
)
init_plan = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(init_plan)
to_kebab_case = init_plan.to_kebab_case
resolve_output_dir = init_plan.resolve_output_dir
find_repo_root = init_plan.find_repo_root


def _make_repo(tmp_path):
    """A throwaway git repo root for resolver tests."""
    (tmp_path / ".git").mkdir()
    return tmp_path.resolve()


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


# --- resolve_output_dir: the resolver that previously had zero coverage ---


def test_provided_path_wins(tmp_path):
    target = tmp_path / "anywhere"
    assert resolve_output_dir(str(target)) == target.resolve()


def test_config_pin_takes_precedence_over_existing_convention(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / "plans").mkdir()  # an existing convention is present...
    (repo / ".claude").mkdir()
    (repo / ".claude" / "make-plan.json").write_text(
        json.dumps({"plans_dir": "docs/plans"})
    )
    monkeypatch.chdir(repo)
    # ...but an explicit pin overrides it.
    assert resolve_output_dir(None) == repo / "docs" / "plans"


def test_repo_root_anchoring_from_subdirectory(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / "plans").mkdir()
    subdir = repo / "apps" / "api"
    subdir.mkdir(parents=True)
    monkeypatch.chdir(subdir)
    # Resolves to the repo-root plans/, NOT apps/api/... — the old cwd bug.
    assert resolve_output_dir(None) == repo / "plans"


def test_honors_existing_plans_dir(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / "plans").mkdir()
    monkeypatch.chdir(repo)
    assert resolve_output_dir(None) == repo / "plans"


def test_honors_existing_memory_bank_plans(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / "memory-bank" / "plans").mkdir(parents=True)
    monkeypatch.chdir(repo)
    assert resolve_output_dir(None) == repo / "memory-bank" / "plans"


def test_plans_dir_preferred_over_claude_plans(tmp_path, monkeypatch):
    # When both exist (the kuuma split), honor the dominant bare plans/.
    repo = _make_repo(tmp_path)
    (repo / "plans").mkdir()
    (repo / ".claude" / "plans").mkdir(parents=True)
    monkeypatch.chdir(repo)
    assert resolve_output_dir(None) == repo / "plans"


def test_default_when_no_convention_exists(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    monkeypatch.chdir(repo)
    assert resolve_output_dir(None) == repo / ".claude" / "plans"


def test_resolution_is_side_effect_free(tmp_path, monkeypatch):
    # Resolving must never create a directory; main() does that at write time.
    repo = _make_repo(tmp_path)
    monkeypatch.chdir(repo)
    resolve_output_dir(None)
    assert not (repo / ".claude" / "plans").exists()
    assert not (repo / "memory-bank").exists()


def test_malformed_pin_falls_through_to_default(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / ".claude").mkdir()
    (repo / ".claude" / "make-plan.json").write_text("{ not valid json")
    monkeypatch.chdir(repo)
    # A broken config must not crash scaffolding; fall through to default.
    assert resolve_output_dir(None) == repo / ".claude" / "plans"


def test_blank_pin_falls_through(tmp_path, monkeypatch):
    repo = _make_repo(tmp_path)
    (repo / ".claude").mkdir()
    (repo / ".claude" / "make-plan.json").write_text(json.dumps({"plans_dir": "  "}))
    monkeypatch.chdir(repo)
    assert resolve_output_dir(None) == repo / ".claude" / "plans"
