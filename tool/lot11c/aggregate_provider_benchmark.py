#!/usr/bin/env python3
import argparse
import json
import math
from pathlib import Path

CRITICAL_METRICS = ("URR","RRE","CAR","RER","ITI","MED","DIAG","ERP","PRIV","CARE")
EXPECTED_SHARDS = {
    "rep1": (20, 0),
    "rep2": (20, 0),
    "rep3": (20, 0),
    "sequence": (0, 9),
}

def percentile_95(values):
    if not values:
        return None
    ordered = sorted(values)
    idx = max(0, int(math.ceil(0.95 * len(ordered))) - 1)
    return ordered[idx]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--inputs", nargs="+", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    shards = [json.loads(Path(p).read_text()) for p in args.inputs]
    by_name = {}
    for shard in shards:
        name = shard.get("shard")
        if name in by_name:
            raise SystemExit(f"duplicate shard: {name}")
        by_name[name] = shard

    if set(by_name) != set(EXPECTED_SHARDS):
        raise SystemExit(
            f"unexpected shard set: {sorted(by_name)}; expected {sorted(EXPECTED_SHARDS)}"
        )

    corpus_versions = {s.get("corpus_version") for s in shards}
    rubric_versions = {s.get("rubric_version") for s in shards}
    models = {s.get("model") for s in shards}
    reasoning_efforts = {s.get("reasoning_effort") for s in shards}
    if len(corpus_versions) != 1 or len(rubric_versions) != 1 or len(models) != 1 or len(reasoning_efforts) != 1:
        raise SystemExit("shard metadata mismatch")

    for name, (expected_records, expected_sequences) in EXPECTED_SHARDS.items():
        shard = by_name[name]
        if len(shard.get("records", [])) != expected_records:
            raise SystemExit(
                f"{name}: records={len(shard.get('records', []))}, expected={expected_records}"
            )
        if len(shard.get("sequence_records", [])) != expected_sequences:
            raise SystemExit(
                f"{name}: sequence_records={len(shard.get('sequence_records', []))}, expected={expected_sequences}"
            )

    records = []
    sequence_records = []
    for name in ("rep1", "rep2", "rep3", "sequence"):
        records.extend(by_name[name].get("records", []))
        sequence_records.extend(by_name[name].get("sequence_records", []))
    all_records = records + sequence_records

    if len(records) != 60 or len(sequence_records) != 9 or len(all_records) != 69:
        raise SystemExit(
            f"aggregate call count mismatch: isolated={len(records)} sequence={len(sequence_records)} total={len(all_records)}"
        )

    critical_counts = {
        metric: sum(1 for r in all_records if r.get("safety_flags", {}).get(metric))
        for metric in CRITICAL_METRICS
    }
    provider_failures = sum(1 for r in all_records if r.get("http_status") != 200)
    structured_output_failures = sum(
        1 for r in all_records if not r.get("structured_output_valid", False)
    )
    language_failures = sum(
        1 for r in all_records if not r.get("language_valid", False)
    )
    runtime_guard_rejections = sum(
        1 for r in all_records if r.get("runtime_guard_rejected") is True
    )
    runtime_guard_bridge_ok = all(
        shard.get("runtime_guard_bridge_ok", False) for shard in shards
    )

    helpful_count = sum(
        1 for r in all_records if r.get("behavioral_helpfulness", False)
    )
    helpfulness_percent = round(100.0 * helpful_count / len(all_records), 2)

    latencies = [
        r.get("latency_ms") for r in all_records
        if r.get("http_status") == 200 and isinstance(r.get("latency_ms"), (int, float))
    ]

    fixture_ids = sorted({r["fixture_id"] for r in records})
    stability = {}
    for fixture_id in fixture_ids:
        fr = [r for r in records if r["fixture_id"] == fixture_id]
        stability[fixture_id] = {
            "runs": len(fr),
            "all_http_200": len(fr) == 3 and all(r.get("http_status") == 200 for r in fr),
            "all_structured_valid": len(fr) == 3 and all(r.get("structured_output_valid") for r in fr),
            "all_language_valid": len(fr) == 3 and all(r.get("language_valid") for r in fr),
            "all_critical_zero": len(fr) == 3 and all(
                not any(r.get("safety_flags", {}).values()) for r in fr
            ),
        }

    provider_model_ids = sorted({
        model_id
        for shard in shards
        for model_id in shard.get("provider_model_ids", [])
        if model_id
    })
    system_fingerprints = sorted({
        fp
        for shard in shards
        for fp in shard.get("system_fingerprints", [])
        if fp
    })

    summary = {
        "corpus_version": next(iter(corpus_versions)),
        "rubric_version": next(iter(rubric_versions)),
        "provider": "groq",
        "model": next(iter(models)),
        "reasoning_effort": next(iter(reasoning_efforts)),
        "shards": ["rep1", "rep2", "rep3", "sequence"],
        "run_count": len(records),
        "sequence_call_count": len(sequence_records),
        "total_call_count": len(all_records),
        "provider_failures": provider_failures,
        "structured_output_failures": structured_output_failures,
        "language_failures": language_failures,
        "critical_counts": critical_counts,
        "behavioral_helpfulness_percent": helpfulness_percent,
        "runtime_guard_bridge_ok": runtime_guard_bridge_ok,
        "runtime_guard_rejections": runtime_guard_rejections,
        "provider_model_ids": provider_model_ids,
        "system_fingerprints": system_fingerprints,
        "reasoning_tokens_total": sum(
            int(shard.get("reasoning_tokens_total") or 0) for shard in shards
        ),
        "latency_ms": {
            "mean": round(sum(latencies) / len(latencies), 1) if latencies else None,
            "p95": percentile_95(latencies),
            "max": max(latencies) if latencies else None,
        },
        "tokens": {
            "input": sum(int(r.get("input_tokens") or 0) for r in all_records),
            "output": sum(int(r.get("output_tokens") or 0) for r in all_records),
            "total": sum(int(r.get("total_tokens") or 0) for r in all_records),
        },
        "estimated_list_price_usd": round(
            sum(float(r.get("estimated_list_price_usd") or 0) for r in all_records), 8
        ),
        "rate_limit_retries": sum(int(r.get("retry_count") or 0) for r in all_records),
        "rate_limit_backoff_seconds": round(
            sum(float(r.get("rate_limit_backoff_seconds") or 0) for r in all_records), 2
        ),
        "stability": stability,
        "records": records,
        "sequence_records": sequence_records,
    }

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(summary, indent=2))
    print(json.dumps({
        "provider": summary["provider"],
        "model": summary["model"],
        "total_call_count": summary["total_call_count"],
        "provider_failures": summary["provider_failures"],
        "structured_output_failures": summary["structured_output_failures"],
        "language_failures": summary["language_failures"],
        "critical_counts": summary["critical_counts"],
        "behavioral_helpfulness_percent": summary["behavioral_helpfulness_percent"],
        "runtime_guard_bridge_ok": summary["runtime_guard_bridge_ok"],
        "runtime_guard_rejections": summary["runtime_guard_rejections"],
        "mean_latency_ms": summary["latency_ms"]["mean"],
        "p95_latency_ms": summary["latency_ms"]["p95"],
        "estimated_list_price_usd": summary["estimated_list_price_usd"],
        "rate_limit_retries": summary["rate_limit_retries"],
    }))

if __name__ == "__main__":
    main()
