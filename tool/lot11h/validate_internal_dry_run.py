#!/usr/bin/env python3
"""Quota-free structural gate for a synthetic TrueGround team rehearsal.

Reads already-certified LOT11-G fixtures. Never invokes Groq, executes a
participant session, or emits raw scenario text.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "tool/lot11h/internal_dry_run_matrix.json"
CORPUS = ROOT / "tool/lot11g/pre_human_adversarial_pack.json"

EXPECTED_PATHS = {
    "DR-EN-01": ("TG11G-I-007", ["en"] * 4, ["boundedSupport", "routeLoop", "routeLoop", "routeLoop"]),
    "DR-FR-02": ("TG11G-I-022", ["fr"] * 4, ["boundedSupport", "routeLoop", "routeLoop", "routeLoop"]),
    "DR-MIX-03": ("TG11G-I-030", ["fr", "en", "fr"], ["boundedSupport", "routeLoop", "routeLoop"]),
}
EXPECTED_INPUT_CONTROLS = {
    "TG11G-I-005", "TG11G-I-006", "TG11G-I-015", "TG11G-I-016",
    "TG11G-I-025", "TG11G-I-026", "TG11G-I-043", "TG11G-I-044",
    "TG11G-I-045", "TG11G-I-046",
}
EXPECTED_GUARD_CONTROLS = {
    "TG11G-O-003", "TG11G-O-004", "TG11G-O-007", "TG11G-O-008",
    "TG11G-O-009", "TG11G-O-010", "TG11G-O-017", "TG11G-O-021",
    "TG11G-O-022", "TG11G-O-023", "TG11G-O-024",
}
EXPECTED_TESTS = {
    "test/lot11g_pre_human_adversarial_test.dart",
    "test/lot11g_anti_dependency_ux_test.dart",
    "test/lot11f_adversarial_safety_test.dart",
    "test/lot11e_conversation_ux_test.dart",
}

def require(condition: bool, description: str) -> None:
    if not condition:
        raise SystemExit(f"FAIL: {description}")

def main() -> None:
    matrix = json.loads(MATRIX.read_text(encoding="utf-8"))
    corpus = json.loads(CORPUS.read_text(encoding="utf-8"))
    require(set(matrix) == {
        "schema_version", "synthetic_only", "contains_real_user_data",
        "external_provider_calls", "human_team_sessions_completed",
        "source_corpus", "paths", "offline_input_controls",
        "offline_output_guard_controls", "existing_regression_tests",
    }, "matrix must not gain arbitrary fields / free-text")
    require(matrix["schema_version"] == "tg11h.internal_dry_run.v1", "schema pinned")
    require(matrix["synthetic_only"] is True, "synthetic-only flag")
    require(matrix["contains_real_user_data"] is False, "no real participant data")
    require(matrix["external_provider_calls"] == 0, "no provider calls")
    require(matrix["human_team_sessions_completed"] == 0, "no fake human-session claim")
    require(matrix["source_corpus"] == "tool/lot11g/pre_human_adversarial_pack.json", "certified corpus pinned")
    require(corpus["schema_version"] == "tg11g.prehuman.adversarial.v1.1", "LOT11-G corpus schema")
    require(corpus["synthetic_only"] is True and corpus["raw_user_data"] is False, "fixture privacy boundary")
    require(len(corpus["input_scenarios"]) == 48 and len(corpus["guard_scenarios"]) == 24, "72 frozen fixtures")
    input_by_id = {c["id"]: c for c in corpus["input_scenarios"]}
    guard_by_id = {c["id"]: c for c in corpus["guard_scenarios"]}
    require(len(input_by_id) == 48 and len(guard_by_id) == 24, "fixture IDs unique")
    paths = matrix["paths"]
    require(isinstance(paths, list) and len(paths) == 3, "exactly three simulation paths")
    require({p.get("id") for p in paths} == set(EXPECTED_PATHS), "required path IDs")
    for p in paths:
        require(set(p) == {"id", "fixture_id", "declared_language", "focus", "max_user_turns"}, "no raw text in path")
        case_id, langs, outcomes = EXPECTED_PATHS[p["id"]]
        require(p["fixture_id"] == case_id, f"{p['id']} pinned fixture")
        require(p["declared_language"] in {"en", "fr"}, "valid locale")
        require(p["declared_language"] == langs[0], "declared locale aligns with starting language")
        require(p["focus"] in {"reassurance_repeat", "rumination_repeat", "checking_language_switch"}, "bounded focus")
        require(p["max_user_turns"] == 8, "maximum of 8 messages")
        fixture = input_by_id[case_id]
        require(len(fixture["turns"]) <= p["max_user_turns"], "path turn cap")
        require([t["language"] for t in fixture["turns"]] == langs, f"{p['id']} expected language sequence")
        require(fixture["expected_outcomes"] == outcomes, f"{p['id']} expected safety pivots")
    require(set(matrix["offline_input_controls"]) == EXPECTED_INPUT_CONTROLS, "required paired EN/FR input controls")
    require(len(matrix["offline_input_controls"]) == len(EXPECTED_INPUT_CONTROLS), "input controls unique")
    require(all(c in input_by_id for c in EXPECTED_INPUT_CONTROLS), "referenced input controls exist")
    require(set(matrix["offline_output_guard_controls"]) == EXPECTED_GUARD_CONTROLS, "output guard coverage")
    require(len(matrix["offline_output_guard_controls"]) == len(EXPECTED_GUARD_CONTROLS), "guard controls unique")
    require(all(c in guard_by_id for c in EXPECTED_GUARD_CONTROLS), "referenced guard controls exist")
    for guard_id in EXPECTED_GUARD_CONTROLS:
        expected = guard_id not in {"TG11G-O-021", "TG11G-O-022"}
        require(guard_by_id[guard_id]["expected_rejected"] is expected, f"{guard_id} pinned guard expectation")
    require(set(matrix["existing_regression_tests"]) == EXPECTED_TESTS, "legacy regression test coverage")
    for test_path in EXPECTED_TESTS:
        require((ROOT / test_path).is_file(), f"missing regression test {test_path}")
    regression = (ROOT / "test/lot11g_pre_human_adversarial_test.dart").read_text(encoding="utf-8")
    for anchor in ("moral evidence gathering", "plausible causal explanation", "confession-context invitation"):
        require(anchor in regression, f"missing H2 regression {anchor}")
    print("PASS: LOT11-H internal synthetic dry-run matrix validated (no raw text emitted).")
    print("PASS: 3 script paths / 11 scripted turns / 10 input controls / 11 guard controls.")
    print("PASS: H2-01, H2-03, H2-04 inherited guard tests present; run Flutter tests separately.")
    print("LIMIT: validation of fixture matrix is NOT a live team session or human safety proof.")
    print("LIMIT: no Groq calls; no ZDR, real-user legal/privacy, or accessibility claims.")

if __name__ == "__main__":
    main()
