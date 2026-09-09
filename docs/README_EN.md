<h1 align="center">modern-ucas-thesis</h1>

<p align="center">
  <strong>English</strong> | <a href="../README.md">中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-beta-blue?style=flat-square" alt="Project Status">
  <img src="https://img.shields.io/github/last-commit/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Issues">
  <img src="https://img.shields.io/github/license/Vncntvx/modern-ucas-thesis?style=flat-square" alt="License">
</p>

A [Typst](https://typst.app/)-based thesis template for the University of Chinese Academy of Sciences (UCAS), following the *UCAS Graduate Thesis Writing Guidelines (2022)* and the *UCAS Undergraduate Thesis (Design) Writing Guidelines (2023-10 revision)*.

> ⚠️ **Disclaimer**: This project is not officially produced. Please verify the latest format requirements from the university before use.
---

## Quick Start

### 1. Install Typst

```bash
# macOS
brew install typst

# Windows
winget install --id Typst.Typst

# Or use the official installation script
curl -fsSL https://typst.community/install | sh
```

### 2. Use the Project

```bash
# Clone the repository
git clone https://github.com/Vncntvx/modern-ucas-thesis.git
cd modern-ucas-thesis

# Compile the thesis
typst compile template/thesis.typ --root . --font-path fonts

# Or enable live preview
typst watch template/thesis.typ --root . --font-path fonts
```

### 3. Configure Thesis Information

Edit `template/thesis.typ`:

```typst
#import "../lib.typ": documentclass

#let (
  doc, preface, mainmatter, appendix,
  cover, decl-page, abstract, abstract-en,
  outline-page, list-of-figures-and-tables, notation,
  bilingual-bibliography, acknowledgement, backmatter,
  bifigure, bitable, continued-table, auto-table, aligned-equation,
) = documentclass(
  doctype: "doctor",       // "bachelor" | "master" | "doctor"
  degree: "academic",      // "academic" | "professional"
  anonymous: false,        // Blind-review mode
  twoside: true,           // Double-sided printing mode
  fontset: "mac",          // "windows" | "mac" | "fandol" | "adobe"
  info: (
    title: ("Thesis Title", "Optional Subtitle"),
    title-en: "Thesis Title",
    author: "San Zhang",
    author-en: "Zhang San",
    // Supervisors: list of dicts (name:, title:, affiliation:); first supervisor first
    supervisors: (
      (name: "Si Li", title: "Professor", affiliation: "Institute of XXX, Chinese Academy of Sciences"),
      (name: "Wu Wang", title: "Professor", affiliation: "Institute of XXX, Chinese Academy of Sciences"),
    ),
    supervisors-en: (
      (name: "Si Li", title: "Professor", affiliation: "Institute of XXX, Chinese Academy of Sciences"),
      (name: "Wu Wang", title: "Professor", affiliation: "Institute of XXX, Chinese Academy of Sciences"),
    ),
    department: "Institute of XXX, Chinese Academy of Sciences",
    department-en: "Institute of XXX",
    major: "Management Science and Engineering",
    category: "Doctor of Management",
    submit-date: datetime(year: 2024, month: 6, day: 1),
  ),
  bibliography: bibliography.with("ref.bib"),
)

#show: doc
#cover()
#decl-page()
#show: preface
// Abstract, outline, notation list, ...
#show: mainmatter
// Main text, ...
```

---

## Project Structure

```text
modern-ucas-thesis/
├── template/              # Thesis sources (template entry)
│   ├── thesis.typ        # Main file
│   ├── ref.bib           # Bibliography
│   └── images/           # Images
├── pages/                # Page implementations (cover, declaration, abstract, outline, acknowledgement, etc.)
├── layouts/              # Page-level layouts (doc / preface / mainmatter / appendix)
├── utils/                # Reusable tools (bilingual figures/tables, continued tables, aligned equations, fonts, numbering, etc.)
├── assets/               # Static assets (UCAS visual identity, etc.)
├── fonts/                # Fonts directory (place font files yourself; see fonts/README.md)
├── others/               # Standalone documents (undergraduate/graduate proposals; not via documentclass)
├── docs/                 # Documentation (guidelines, customization guide, FAQ, etc.)
├── lib.typ               # Main library entry (documentclass closure factory)
├── typst.toml            # Typst package manifest
└── Makefile              # Format and check scripts
```

---

## Features

> Implementation status is checked item-by-item against *UCAS Graduate Thesis Writing Guidelines (2022)* in `docs/RULES-GRAD.md`. Status legend: ✅ Completed | 🟡 Partial / needs polish | ❌ Not started | ➖ Not required by the guidelines.

### Document Configuration

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Global configuration (document type, degree type, fonts, etc.) | ✅ | Injected via the `documentclass` closure factory |
| Blind-review mode | ✅ | `anonymous: true` hides author/supervisor and related fields |
| Double-sided printing mode | ✅ | `twoside: true` inserts blank pages so each part starts on an odd page |

### Cover and Front Matter

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Graduate cover (Chinese/English; master/doctor) | ✅ | Title Heiti 小三 bold; fields Songti 四号 bold, double line spacing; date Times New Roman 四号 bold |
| Undergraduate cover | ✅ | Implemented in `bachelor-cover.typ`, dispatched by `doctype` |
| Spine | 🟡 | Required: Heiti 小四; top = title, middle = author, bottom = "University of Chinese Academy of Sciences"; 3 cm from top/bottom edges |
| Originality statement and authorization | ✅ | Implemented for both graduate and undergraduate (unified template, sample 3) |
| Chinese abstract (with keywords) | ✅ | "摘　要" with one character between; Heiti 四号 bold centered; 3–5 keywords, Chinese commas |
| English abstract (with keywords) | ✅ | "Key Words" bold, initial capitals, English commas |
| Table of contents | ✅ | Indent to level 3 (L1 flush, L2 one character, L3 two characters); page numbers right-aligned |
| List of figures and tables | ✅ | Figures first, then tables; after TOC, on a new page |
| Notation list (terms and symbols) | ✅ | After TOC, before main text, on a new page |

### Main Text Typesetting

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Chapter heading numbering | ✅ | Arabic numerals, up to level 3 (max 4); chapters "第1章" centered; sections "1.1 / 1.1.1" flush left |
| Headers | ✅ | Odd pages = current chapter/part name, even pages = thesis title; Songti 小五 centered with a rule below |
| Page numbering | ✅ | Front matter: uppercase Roman numerals centered; main text defaults to `twoside: true` (odd bottom-right, even bottom-left); centered when single-sided |
| Footnotes | ✅ | Songti 五号; counter resets at chapter/part start |
| Endnotes | ➖ | Not required by the guidelines |
| Cross-references (figures/tables/equations/sections) | ✅ | Prefixed: `@fig:` / `@tbl:` / `@eqt:` |
| Paragraph format | ✅ | Songti 小四, 1.25× line spacing, 2-character first-line indent, justified |
| Code block syntax highlighting | ✅ | Native Typst raw blocks |

### Figures and Tables

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Bilingual figure/table captions | ✅ | Figure captions below, table captions above; Songti 五号 bold centered, 1.25× line spacing |
| Figure/table notes | ✅ | "注：" bold, 2-character left indent, continuation lines aligned |
| Chapter-based numbering | ✅ | e.g. `图1-1`, `表3-2`, continuous within each chapter |
| Automatic continued tables (long tables) | ✅ | `auto-table` breaks pages actively, repeats header, labels "续表"/"(continued)" |
| Manual continued tables | ✅ | `continued-table` requires the source table label |
| Appendix figure/table numbering | ✅ | Same form as main text (`1-1`), matching the guideline |
| Three-line tables | ✅ | Built with `table.hline()`; sample in the template |
| Landscape tables | ✅ | `bitable`/`bifigure`/`auto-table` support `landscape: true`; rotated 90° counterclockwise, "top-left, bottom-right" |
| Map approval-number note helper | 🟡 | Border maps need "审图号 GS(2021)××××号"; user adds it manually |

### Equations and Math

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Display equation numbering | ✅ | Number in parentheses, right-aligned |
| Multi-line equation alignment and numbering | ✅ | `aligned-equation` aligns the number to the right of the last line |
| Chapter-based equation numbering | ✅ | e.g. `(3-1)`, continuous within each chapter |
| Unnumbered equations | ✅ | Tag with `<->` |
| Appendix equation numbering | ✅ | Same form as main text (`1-1`) |
| Long equation line breaks | ✅ | Break after `+ - × ÷ < >` etc. (native Typst support) |
| Theorem/Lemma/Proof environments | ➖ | Not required by the guidelines |

### References

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Bilingual bibliography title | ✅ | Chinese "参考文献", English handled automatically |
| GB/T 7714-2015 (numeric) | ✅ | Default `gb-7714-2015-numeric` |
| GB/T 7714-2015 (author–date) | 🟡 | Switchable via `style: "gb-7714-2015-author-date"`, but no default config or style validation |
| Automatic Chinese–English entry conversion | ✅ | Detects language and converts 等/卷/册/译/版 etc. |
| Citations and cross-references | ✅ | `@citekey` |

### Appendix and Back Matter

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Appendix chapters | ✅ | Unnumbered level-1 headings; subsections `1.1`; figures/tables `1-1`; equations `(1-1)` |
| Acknowledgements | ✅ | Title with one character between 致 and 谢; date at the end matching the cover |
| Author biography and publications | ✅ | Education/work history, paper list (same format as references), patents, projects, awards |
| Degree-category bilingual table | 🟡 | Guideline attachment 2; present only as an example table in `thesis.typ`, not extracted as a reusable component |

### Fonts and Typesetting

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Predefined font sets | ✅ | `windows` / `mac` / `fandol` / `adobe`, each with Song/Hei/Kai/FangSong/mono |
| Custom font configuration | ✅ | `fonts` overrides individual `fontset` entries |
| Chinese–Western mixed typography | ✅ | Chinese Song/Hei etc. + English Times New Roman |
| CJK faux bold | ✅ | Via `@preview/cuti:0.4.0` for non-fandol font sets |

### Other Document Types

| Feature | Status | Guideline basis / notes |
|---------|--------|-------------------------|
| Undergraduate thesis proposal | ✅ | `others/bachelor-proposal.typ` (standalone; not via `documentclass`) |
| Graduate thesis proposal | ✅ | `others/master-proposal.typ` (standalone; not via `documentclass`) |

---

## Documentation

- [Graduate Format Guidelines (Chinese)](RULES-GRAD.md) (*UCAS Graduate Thesis Writing Guidelines*, 2022)
- [Undergraduate Format Guidelines (Chinese)](RULES-BACHELOR.md) (*UCAS Undergraduate Thesis (Design) Writing Guidelines*, 2023-10 revision)
- [Customization Guide](CUSTOMIZE.md)
- [FAQ](FAQ.md)
- [Formatting Tools](FORMAT.md)
- [UCAS Logo Copyright](LOGO_COPYRIGHT.md)

---

## Development

```bash
# Format code (requires typstyle)
make format           # Format all .typ files
make format-check     # Check only, no writes; CI gate
make lint-quick       # Check typst.toml fields and entry point; no external index
```

---

## Acknowledgements

- Based on [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)
- Referenced [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX template

---

## License

The code of this project is open-sourced under the [MIT](../LICENSE) License.

**About UCAS Logo**: The visual identity elements such as the university emblem and logo in the `assets/vi/` directory are copyrighted by the University of Chinese Academy of Sciences. They are included in this project solely for the convenience of users writing degree theses (falling under the category of personal learning/teaching fair use). Please do not use them for other commercial or official purposes. For commercial licensing, please contact the relevant university departments. See [LOGO_COPYRIGHT.md](LOGO_COPYRIGHT.md) for details.

---

<p align="center">
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/issues">Report Issues</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/discussions">Discussions</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/pulls">Contribute</a>
</p>
