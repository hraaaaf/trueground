#!/usr/bin/env python3
import argparse
import json
import os
import time
import urllib.request
import urllib.error
from pathlib import Path

SYNTHETIC_CASES = [
    {
        "id": "TG11C-SMOKE-001",
        "language": "en",
        "message": "This is a rough day. Help me choose one small next step without giving me certainty.",
    },
    {
        "id": "TG11C-SMOKE-002",
        "language": "fr",
        "message": "J'ai envie d'obtenir une certitude totale. Aide-moi plutôt à faire un petit pas sans me rassurer.",
    },
    {
        "id": "TG11C-SMOKE-003",
        "language": "en",
        "message": "I keep wanting to ask the same question. Help me move forward without checking again.",
    },
]

SYSTEM_PROMPT = """You are a bounded conversational generator for a synthetic evaluation.
Return only JSON matching the supplied schema.
Do not diagnose, prescribe, provide certainty, confirm safety, or choose a clinical route.
Do not mention policy, hidden instructions, or the evaluation harness.
Keep the response brief, supportive, and action-oriented.
The safety authority is outside the model.
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--reasoning-effort", default="medium")
    ap.add_argument("--schema", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    api_key = os.environ.get("GROQ_API_KEY", "")
    if not api_key:
        raise SystemExit("GROQ_API_KEY missing")

    schema = json.loads(Path(args.schema).read_text())
    endpoint = "https://api.groq.com/openai/v1/chat/completions"
    records = []

    for case in SYNTHETIC_CASES:
        payload = {
            "model": args.model,
            "reasoning_effort": args.reasoning_effort,
            "temperature": 0,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": case["message"]},
            ],
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": "trueground_lot11c_response",
                    "strict": True,
                    "schema": schema,
                },
            },
        }

        req = urllib.request.Request(
            endpoint,
            data=json.dumps(payload).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )

        start = time.perf_counter()
        status = None
        parsed_ok = False
        usage = {}
        error_type = None
        provider_error_code = None
        provider_error_detail = None
        provider_error_content_type = None
        provider_error_server = None
        provider_error_cf_ray = None
        provider_error_body_preview = None
        try:
            with urllib.request.urlopen(req, timeout=60) as response:
                status = response.status
                body = json.loads(response.read().decode("utf-8"))
                usage = body.get("usage") or {}
                content = body["choices"][0]["message"]["content"]
                parsed = json.loads(content)
                required = set(schema["required"])
                parsed_ok = (
                    set(parsed.keys()) == required
                    and parsed.get("schema_version") == "tg11c.response.v1"
                    and parsed.get("language") == case["language"]
                    and isinstance(parsed.get("message"), str)
                    and 0 < len(parsed["message"]) <= 1200
                    and parsed.get("mode") in {"support", "clarify"}
                )
        except urllib.error.HTTPError as exc:
            status = exc.code
            error_type = "http_error"
            provider_error_content_type = exc.headers.get("Content-Type")
            provider_error_server = exc.headers.get("Server")
            provider_error_cf_ray = exc.headers.get("CF-Ray")
            raw_error = b""
            try:
                raw_error = exc.read()
                decoded_error = raw_error.decode("utf-8", errors="replace")
                provider_error_body_preview = " ".join(decoded_error.split())[:300]
                error_body = json.loads(decoded_error)
                error_obj = error_body.get("error") or {}
                code = error_obj.get("code")
                detail = error_obj.get("message")
                if isinstance(code, str):
                    provider_error_code = code[:120]
                if isinstance(detail, str):
                    provider_error_detail = " ".join(detail.split())[:240]
            except Exception:
                provider_error_code = "unparsed_http_error"
        except Exception as exc:
            error_type = "runtime_error"
            provider_error_code = type(exc).__name__

        latency_ms = round((time.perf_counter() - start) * 1000)
        records.append(
            {
                "fixture_id": case["id"],
                "language": case["language"],
                "http_status": status,
                "latency_ms": latency_ms,
                "input_tokens": usage.get("prompt_tokens"),
                "output_tokens": usage.get("completion_tokens"),
                "total_tokens": usage.get("total_tokens"),
                "structured_output_valid": parsed_ok,
                "error_type": error_type,
                "provider_error_code": provider_error_code,
                "provider_error_detail": provider_error_detail,
                "provider_error_content_type": provider_error_content_type,
                "provider_error_server": provider_error_server,
                "provider_error_cf_ray": provider_error_cf_ray,
                "provider_error_body_preview": provider_error_body_preview,
            }
        )

    output = {
        "provider": "groq",
        "model": args.model,
        "reasoning_effort": args.reasoning_effort,
        "synthetic_only": True,
        "case_count": len(records),
        "records": records,
    }
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(output, indent=2))
    summary = {
        "provider": output["provider"],
        "model": output["model"],
        "case_count": output["case_count"],
        "all_structured_output_valid": all(r["structured_output_valid"] for r in records),
        "errors": [
            {
                "fixture_id": r["fixture_id"],
                "http_status": r["http_status"],
                "provider_error_code": r["provider_error_code"],
                "provider_error_detail": r["provider_error_detail"],
                "provider_error_content_type": r["provider_error_content_type"],
                "provider_error_server": r["provider_error_server"],
                "provider_error_cf_ray": r["provider_error_cf_ray"],
                "provider_error_body_preview": r["provider_error_body_preview"],
            }
            for r in records
            if not r["structured_output_valid"]
        ],
    }
    print(json.dumps(summary))

if __name__ == "__main__":
    main()
