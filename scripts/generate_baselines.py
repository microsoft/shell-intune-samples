#!/usr/bin/env python3
"""Generate Intune custom compliance assets from mSCP macOS baselines."""

from __future__ import annotations

import argparse
import json
import math
import re
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

MACOS_VERSION = "26.0"
MAX_RULES_PER_PART = 90
SUPPORTED_RESULT_TYPES = {"string": "String", "integer": "Int64"}
DEFAULT_MORE_INFO = "https://github.com/usnistgov/macos_security"
EXPLICIT_USER_CONTEXT_RULE_IDS = {
    "os_show_filename_extensions_enable",
    "system_settings_bluetooth_sharing_disable",
    "system_settings_hot_corners_secure",
    "system_settings_location_services_disable",
    "system_settings_location_services_enable",
}


@dataclass
class SupportedRule:
    rule_id: str
    title: str
    discussion: str
    section: str
    source_path: str
    rule_url: str
    context: str
    data_type: str
    operand: Any
    shell: str
    remediation_title: str


@dataclass
class UnsupportedRule:
    rule_id: str
    section: str
    source_path: str
    reason: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mscp-root", required=True, help="Path to local mSCP clone")
    parser.add_argument(
        "--repo-root",
        default=str(Path(__file__).resolve().parents[1]),
        help="Path to this repo root",
    )
    return parser.parse_args()


def load_yaml(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    return data if isinstance(data, dict) else {}


def rule_url_from_source(source_path: str) -> str:
    return f"https://github.com/usnistgov/macos_security/blob/main/{source_path.replace(chr(92), '/')}"


def choose_macos_enforcement(rule: dict[str, Any]) -> tuple[dict[str, Any] | None, str | None]:
    mac = ((rule.get("platforms") or {}).get("macOS") or {})
    if not isinstance(mac, dict):
        return None, None

    version_block = mac.get(MACOS_VERSION)
    if isinstance(version_block, dict) and isinstance(version_block.get("enforcement_info"), dict):
        return version_block["enforcement_info"], f"platforms.macos.{MACOS_VERSION}.enforcement_info"

    if isinstance(mac.get("enforcement_info"), dict):
        return mac["enforcement_info"], "platforms.macos.enforcement_info"

    for fallback_version in ("15.0", "14.0"):
        fallback_block = mac.get(fallback_version)
        if isinstance(fallback_block, dict) and isinstance(fallback_block.get("enforcement_info"), dict):
            return fallback_block["enforcement_info"], f"platforms.macos.{fallback_version}.enforcement_info"

    return None, None


def context_for_rule(rule_id: str, shell: str, discussion: str) -> str:
    text = f"{shell}\n{discussion}"
    if rule_id in EXPLICIT_USER_CONTEXT_RULE_IDS:
        return "user"
    if any(token in text for token in ("CURRENT_USER", "sudo -u", "-currentHost", "last logged in user")):
        return "user"
    return "root"


def resolve_odv(rule: dict[str, Any], baseline_parent: str) -> str | None:
    odv = rule.get("odv")
    if not isinstance(odv, dict):
        return None

    candidate_keys = [
        baseline_parent,
        baseline_parent.replace("-", "_"),
        baseline_parent.replace("_macos_26.0", ""),
        baseline_parent.replace("_macos_26.0", "").replace("-", "_"),
        "recommended",
    ]
    for key in candidate_keys:
        if key in odv:
            return str(odv[key])
    return None


def substitute_odv(text: str, odv_value: str | None) -> str:
    if "$ODV" not in text:
        return text
    return text.replace("$ODV", odv_value or "0")


def remediation_title(rule_title: str, operand: Any) -> str:
    title = rule_title.strip().replace("$ODV", str(operand))
    title = re.sub(r"\s+", " ", title)
    if len(title) > 150:
        title = title[:147].rstrip() + "..."
    return f"{title}. Value discovered was {{ActualValue}}."


def normalize_operand(result_value: Any, result_type: str) -> Any:
    if result_type == "integer":
        if isinstance(result_value, int):
            return result_value
        if isinstance(result_value, str) and result_value.strip():
            return int(str(result_value).strip())
        return 0
    return str(result_value)


def build_rule_record(
    rule_id: str,
    section: str,
    source_path: str,
    baseline_parent: str,
    rule: dict[str, Any],
) -> SupportedRule | UnsupportedRule:
    enforcement_info, _ = choose_macos_enforcement(rule)
    if not enforcement_info:
        return UnsupportedRule(rule_id, section, source_path, "No macOS enforcement_info")

    check = enforcement_info.get("check")
    if not isinstance(check, dict):
        return UnsupportedRule(rule_id, section, source_path, "No check block")

    shell = check.get("shell")
    result = check.get("result")
    if not isinstance(shell, str) or not shell.strip():
        return UnsupportedRule(rule_id, section, source_path, "No shell check")
    if not isinstance(result, dict) or not result:
        return UnsupportedRule(rule_id, section, source_path, "No result metadata")

    result_type = next(iter(result.keys()))
    if result_type not in SUPPORTED_RESULT_TYPES:
        return UnsupportedRule(rule_id, section, source_path, f"Unsupported result type: {result_type}")

    odv_value = resolve_odv(rule, baseline_parent)
    rendered_shell = substitute_odv(shell.rstrip(), odv_value)
    raw_operand = result[result_type]
    if isinstance(raw_operand, str):
        raw_operand = substitute_odv(raw_operand, odv_value)
    operand = normalize_operand(raw_operand, result_type)
    title = str(rule.get("title") or rule_id)
    discussion = str(rule.get("discussion") or "")

    return SupportedRule(
        rule_id=rule_id,
        title=title,
        discussion=discussion,
        section=section,
        source_path=source_path,
        rule_url=rule_url_from_source(source_path),
        context=context_for_rule(rule_id, rendered_shell, discussion),
        data_type=SUPPORTED_RESULT_TYPES[result_type],
        operand=operand,
        shell=rendered_shell,
        remediation_title=remediation_title(title, operand),
    )


def slugify_baseline(name: str) -> str:
    return name.replace(".yaml", "")


def chunked(items: list[SupportedRule], size: int) -> list[list[SupportedRule]]:
    return [items[index : index + size] for index in range(0, len(items), size)]


def to_json(obj: Any) -> str:
    return json.dumps(obj, indent=2, ensure_ascii=True)


def bash_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def make_script(part_rules: list[SupportedRule]) -> str:
    lines: list[str] = [
        "#!/bin/bash",
        "",
        "normalize_output() {",
        "  local value=\"$1\"",
        "  value=${value//$'\\r'/ }",
        "  value=${value//$'\\n'/ }",
        "  value=${value//$'\\t'/ }",
        "  printf '%s' \"$value\" | /usr/bin/sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'",
        "}",
        "",
        "json_escape() {",
        "  local value=\"$1\"",
        "  value=${value//\\\\/\\\\\\\\}",
        "  value=${value//\\\"/\\\\\\\"}",
        "  printf '%s' \"$value\"",
        "}",
        "",
        "emit_separator=\"\"",
        "",
        "emit_string_field() {",
        "  local name=\"$1\"",
        "  local value=\"$2\"",
        "  printf '%s\"%s\":\"%s\"' \"$emit_separator\" \"$name\" \"$(json_escape \"$value\")\"",
        "  emit_separator=','",
        "}",
        "",
        "emit_int_field() {",
        "  local name=\"$1\"",
        "  local value=\"$2\"",
        "  if [[ ! \"$value\" =~ ^-?[0-9]+$ ]]; then",
        "    >&2 echo \"[$name] expected integer output but got: $value\"",
        "    value=0",
        "  fi",
        "  printf '%s\"%s\":%s' \"$emit_separator\" \"$name\" \"$value\"",
        "  emit_separator=','",
        "}",
        "",
        "printf '{'",
    ]

    for index, rule in enumerate(part_rules, start=1):
        func_name = f"run_check_{index:03d}"
        delimiter = f"__MSCP_RULE_{index:03d}__"
        lines.extend(
            [
                "",
                f"# {rule.rule_id}",
                f"{func_name}() {{",
                f"  /bin/bash <<'{delimiter}'",
                rule.shell,
                delimiter,
                "}",
                f"raw_output=\"$({func_name} 2>/dev/null || true)\"",
                "normalized_output=\"$(normalize_output \"$raw_output\")\"",
            ]
        )
        if rule.data_type == "Int64":
            lines.append(f"emit_int_field \"{rule.rule_id}\" \"$normalized_output\"")
        else:
            lines.append(f"emit_string_field \"{rule.rule_id}\" \"$normalized_output\"")

    lines.extend(["", "printf '}'", ""])
    return "\n".join(lines)


def make_rules_json(part_rules: list[SupportedRule]) -> dict[str, Any]:
    rules: list[dict[str, Any]] = []
    for rule in part_rules:
        rules.append(
            {
                "SettingName": rule.rule_id,
                "Operator": "IsEquals",
                "DataType": rule.data_type,
                "Operand": rule.operand,
                "MoreInfoUrl": rule.rule_url or DEFAULT_MORE_INFO,
                "RemediationStrings": [
                    {
                        "Language": "en_US",
                        "Title": rule.remediation_title,
                        "Description": "See the linked mSCP rule for implementation and remediation guidance.",
                    }
                ],
            }
        )
    return {"Rules": rules}


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def render_baseline_readme(
    baseline_name: str,
    title: str,
    description: str,
    manifest: dict[str, Any],
) -> str:
    lines = [
        f"# {baseline_name}",
        "",
        title,
        "",
        description.strip() if description.strip() else "Generated Intune custom compliance assets for this mSCP baseline.",
        "",
        "## Generated policy parts",
        "",
    ]

    for part in manifest["parts"]:
        lines.extend(
            [
                f"- `{part['name']}` - context: **{part['context']}**, rules: **{part['ruleCount']}**",
            ]
        )

    lines.extend(
        [
            "",
            "## Notes",
            "",
            f"- Supported rules generated: **{manifest['supportedRuleCount']}**",
            f"- Unsupported rules skipped: **{manifest['unsupportedRuleCount']}**",
            "- Use one Intune custom compliance policy per part.",
            "- For `user` context parts, set **Run this script using the logged on credentials** to **Yes**.",
            "- For `root` context parts, set **Run this script using the logged on credentials** to **No**.",
            "",
        ]
    )
    return "\n".join(lines)


def generate(repo_root: Path, mscp_root: Path) -> None:
    rules_dir = mscp_root / "src" / "mscp" / "data" / "rules"
    baselines_dir = mscp_root / "src" / "mscp" / "data" / "baselines" / "macos"
    output_dir = repo_root / "generated-baselines"
    summary_dir = repo_root / "docs"

    if output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    rule_index: dict[str, tuple[dict[str, Any], str]] = {}
    for path in sorted(rules_dir.rglob("*.yaml")):
        data = load_yaml(path)
        rule_id = str(data.get("id") or path.stem)
        relative_path = str(path.relative_to(mscp_root)).replace("\\", "/")
        rule_index[rule_id] = (data, relative_path)

    summary_rows: list[dict[str, Any]] = []
    summary_lines = [
        "# Generated baseline summary",
        "",
        "These assets were generated from the mSCP macOS 26.0 baseline files.",
        "",
        "| Baseline | Supported rules | Unsupported rules | Policy parts |",
        "| --- | ---: | ---: | ---: |",
    ]

    for baseline_path in sorted(baselines_dir.glob("*.yaml")):
        baseline = load_yaml(baseline_path)
        baseline_name = slugify_baseline(baseline_path.name)
        baseline_parent = str(baseline.get("parent_values") or baseline_name)
        baseline_folder = output_dir / baseline_name
        baseline_folder.mkdir(parents=True, exist_ok=True)

        supported_rules: list[SupportedRule] = []
        unsupported_rules: list[UnsupportedRule] = []

        for section in baseline.get("profile", []):
            section_name = str(section.get("section") or "Uncategorized")
            for rule_id in section.get("rules", []):
                rule_record = rule_index.get(rule_id)
                if not rule_record:
                    unsupported_rules.append(
                        UnsupportedRule(str(rule_id), section_name, "", "Rule file not found in local mSCP clone")
                    )
                    continue
                rule, source_path = rule_record
                record = build_rule_record(str(rule_id), section_name, source_path, baseline_parent, rule)
                if isinstance(record, SupportedRule):
                    supported_rules.append(record)
                else:
                    unsupported_rules.append(record)

        parts: list[dict[str, Any]] = []
        part_number = 0
        for context in ("root", "user"):
            context_rules = [rule for rule in supported_rules if rule.context == context]
            for chunk in chunked(context_rules, MAX_RULES_PER_PART):
                part_number += 1
                part_name = f"part-{part_number:02d}-{context}"
                part_dir = baseline_folder / part_name
                part_dir.mkdir(parents=True, exist_ok=True)

                write_text(part_dir / "discovery.sh", make_script(chunk))
                (part_dir / "discovery.sh").chmod(0o755)
                write_text(part_dir / "rules.json", to_json(make_rules_json(chunk)))
                write_text(
                    part_dir / "manifest.json",
                    to_json(
                        {
                            "baseline": baseline_name,
                            "part": part_name,
                            "context": context,
                            "ruleCount": len(chunk),
                            "settingNames": [rule.rule_id for rule in chunk],
                        }
                    ),
                )
                parts.append(
                    {
                        "name": part_name,
                        "context": context,
                        "ruleCount": len(chunk),
                        "path": str(part_dir.relative_to(repo_root)).replace("\\", "/"),
                    }
                )

        baseline_manifest = {
            "baseline": baseline_name,
            "title": baseline.get("title"),
            "description": baseline.get("description"),
            "supportedRuleCount": len(supported_rules),
            "unsupportedRuleCount": len(unsupported_rules),
            "partCount": len(parts),
            "parts": parts,
        }
        write_text(baseline_folder / "manifest.json", to_json(baseline_manifest))
        write_text(
            baseline_folder / "unsupported-rules.json",
            to_json(
                [
                    {
                        "ruleId": entry.rule_id,
                        "section": entry.section,
                        "sourcePath": entry.source_path,
                        "reason": entry.reason,
                    }
                    for entry in unsupported_rules
                ]
            ),
        )
        write_text(
            baseline_folder / "README.md",
            render_baseline_readme(
                baseline_name=baseline_name,
                title=str(baseline.get("title") or baseline_name),
                description=str(baseline.get("description") or ""),
                manifest=baseline_manifest,
            ),
        )

        summary_rows.append(
            {
                "baseline": baseline_name,
                "supportedRuleCount": len(supported_rules),
                "unsupportedRuleCount": len(unsupported_rules),
                "partCount": len(parts),
            }
        )
        summary_lines.append(
            f"| `{baseline_name}` | {len(supported_rules)} | {len(unsupported_rules)} | {len(parts)} |"
        )

    write_text(output_dir / "summary.json", to_json(summary_rows))
    write_text(summary_dir / "baseline-generation-summary.md", "\n".join(summary_lines) + "\n")


def main() -> None:
    args = parse_args()
    generate(repo_root=Path(args.repo_root).resolve(), mscp_root=Path(args.mscp_root).resolve())


if __name__ == "__main__":
    main()
