#!/usr/bin/env python3
"""Export portfolio project-details JSON to a Lovable/AI-ready PDF.

Accepts the schema used by examples/eats365-scan-to-order.json
(fields as object with en/zh; sections with subtitle/body objects).

Also accepts the older script format (fields as list; sections with
subtitle_en/subtitle_zh/en/zh).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from fpdf import FPDF

DEFAULT_FONTS = (
    "/Library/Fonts/Arial Unicode.ttf",
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/Library/Fonts/Arial.ttf",
)


class PortfolioPDF(FPDF):
    def footer(self):
        self.set_y(-15)
        self.set_font("Portfolio", size=8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}/{{nb}}", align="C")


def add_heading(pdf: PortfolioPDF, text: str, size: int = 14, color=(30, 30, 30)):
    pdf.set_font("Portfolio", size=size)
    pdf.set_text_color(*color)
    pdf.multi_cell(0, 8, text)
    pdf.ln(2)


def add_label(pdf: PortfolioPDF, text: str):
    pdf.set_font("Portfolio", size=9)
    pdf.set_text_color(100, 100, 100)
    pdf.multi_cell(0, 5, text)
    pdf.ln(1)


def add_body(pdf: PortfolioPDF, text: str, size: int = 10):
    pdf.set_font("Portfolio", size=size)
    pdf.set_text_color(40, 40, 40)
    pdf.multi_cell(0, 6, text)
    pdf.ln(3)


def add_divider(pdf: PortfolioPDF):
    pdf.set_draw_color(220, 220, 220)
    y = pdf.get_y()
    pdf.line(10, y, 200, y)
    pdf.ln(6)


def normalize_content(raw: dict) -> dict:
    """Normalize object-fields / list-fields schemas into one shape."""
    fields_raw = raw.get("fields", [])
    fields: list[dict] = []
    if isinstance(fields_raw, dict):
        label_map = {
            "title": "Title",
            "short_description": "Short description",
            "category": "Category",
            "client": "Client",
            "duration": "Duration",
        }
        for key, label in label_map.items():
            if key not in fields_raw:
                continue
            item = fields_raw[key]
            fields.append(
                {
                    "key": key,
                    "label": label,
                    "en": item.get("en", ""),
                    "zh": item.get("zh", ""),
                }
            )
    else:
        fields = list(fields_raw)

    sections: list[dict] = []
    for section in raw.get("sections", []):
        if "subtitle" in section or "body" in section:
            subtitle = section.get("subtitle") or {}
            body = section.get("body") or {}
            sections.append(
                {
                    "key": section.get("key", ""),
                    "label": section.get("label", ""),
                    "subtitle_en": subtitle.get("en", ""),
                    "subtitle_zh": subtitle.get("zh", ""),
                    "en": body.get("en", ""),
                    "zh": body.get("zh", ""),
                }
            )
        else:
            sections.append(section)

    return {
        "project_slug": raw.get("project_slug", ""),
        "project_type": raw.get("project_type", "portfolio_project_details"),
        "target_platform": raw.get("target_platform", "lovable"),
        "reference_url": raw.get("reference_url", ""),
        "portfolio_reference": raw.get("portfolio_reference", ""),
        "fields": fields,
        "sections": sections,
        "lovable_mapping": raw.get("lovable_mapping") or {},
        "design_assets": raw.get("design_assets") or [],
    }


def resolve_font(explicit: str | None) -> str:
    if explicit:
        path = Path(explicit)
        if not path.is_file():
            raise FileNotFoundError(f"Font not found: {explicit}")
        return str(path)
    for candidate in DEFAULT_FONTS:
        if Path(candidate).is_file():
            return candidate
    raise FileNotFoundError(
        "No Unicode TTF found. Pass --font /path/to/font.ttf "
        "(e.g. Arial Unicode)."
    )


def build_pdf(content: dict, font_path: str, output: Path) -> None:
    pdf = PortfolioPDF()
    pdf.alias_nb_pages()
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_font("Portfolio", "", font_path)
    pdf.add_page()

    add_heading(pdf, "PORTFOLIO PROJECT COPY — AI / LOVABLE READY", size=16)
    add_body(pdf, "Structured content export for Melessa Chu portfolio website.", size=9)
    pdf.ln(2)

    meta_lines = [
        f"project_slug: {content['project_slug']}",
        f"project_type: {content['project_type']}",
        f"target_platform: {content['target_platform']}",
        f"reference_url: {content['reference_url']}",
        f"portfolio_reference: {content['portfolio_reference']}",
    ]
    add_label(pdf, "METADATA")
    add_body(pdf, "\n".join(meta_lines), size=9)
    add_divider(pdf)

    add_heading(pdf, "PROJECT FIELDS", size=13)
    for field in content["fields"]:
        add_label(pdf, f"[{field['key']}] {field['label']}")
        add_label(pdf, "EN:")
        add_body(pdf, field.get("en", ""))
        add_label(pdf, "ZH:")
        add_body(pdf, field.get("zh", ""))
        add_divider(pdf)

    add_heading(pdf, "PROJECT DETAIL SECTIONS", size=13)
    pdf.ln(2)
    for section in content["sections"]:
        add_label(pdf, f"[section_key: {section.get('key', '')}]")
        add_heading(pdf, section.get("label", ""), size=12)
        add_label(pdf, "subtitle_en:")
        add_body(pdf, section.get("subtitle_en", ""), size=9)
        add_label(pdf, "subtitle_zh:")
        add_body(pdf, section.get("subtitle_zh", ""), size=9)
        add_label(pdf, "EN:")
        add_body(pdf, section.get("en", ""))
        add_label(pdf, "ZH:")
        add_body(pdf, section.get("zh", ""))
        add_divider(pdf)

    mapping = content.get("lovable_mapping") or {}
    if mapping:
        pdf.add_page()
        add_heading(pdf, "LOVABLE PAGE MAPPING", size=13)
        lines = [
            f"page_route: {mapping.get('page_route', '')}",
            f"hero_title ← {mapping.get('hero_title', '')}",
            f"hero_subtitle ← {mapping.get('hero_subtitle', '')}",
            f"meta_category ← {mapping.get('meta_category', '')}",
            f"meta_client ← {mapping.get('meta_client', '')}",
            f"meta_duration ← {mapping.get('meta_duration', '')}",
            "",
            "content_sections (in order):",
            *[f"  - {s}" for s in mapping.get("content_sections", [])],
        ]
        add_body(pdf, "\n".join(lines), size=9)
        add_divider(pdf)

    assets = content.get("design_assets") or []
    if assets:
        add_heading(pdf, "DESIGN ASSETS", size=13)
        add_body(pdf, "\n".join(f"• {a}" for a in assets), size=9)
        add_divider(pdf)

    add_heading(pdf, "USAGE NOTES FOR AI", size=13)
    add_body(
        pdf,
        """1. Use EN copy for the default English portfolio page; add ZH as a localized variant if the site supports bilingual project pages.
2. Follow the section order in content_sections to match the existing project details template (see portfolio_reference).
3. Each section_key maps to one H2 block under "My Approach" on the project page.
4. subtitle_en / subtitle_zh can be used as H3 subheadings within each section.
5. Keep tone: professional, clear, enthusiastic; concrete but not exaggerated.""",
        size=9,
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    pdf.output(str(output))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Export portfolio project-details JSON to PDF."
    )
    parser.add_argument(
        "--input",
        "-i",
        required=True,
        help="Path to portfolio JSON (see examples/eats365-scan-to-order.json)",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        help="Output PDF path",
    )
    parser.add_argument(
        "--font",
        default=None,
        help="Path to a Unicode TTF (default: system Arial Unicode if present)",
    )
    args = parser.parse_args(argv)

    input_path = Path(args.input).expanduser().resolve()
    output_path = Path(args.output).expanduser().resolve()
    if not input_path.is_file():
        print(f"Input not found: {input_path}", file=sys.stderr)
        return 1

    raw = json.loads(input_path.read_text(encoding="utf-8"))
    content = normalize_content(raw)
    font_path = resolve_font(args.font)
    build_pdf(content, font_path, output_path)
    print(f"PDF saved: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
