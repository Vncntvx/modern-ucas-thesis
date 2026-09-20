# AGENTS.md

This file provides guidance to Code Agent when working with code in this repository.

## Project overview

A Typst-based thesis template for the University of Chinese Academy of Sciences (UCAS), package `modern-ucas-thesis` (v0.3.0, entry point `lib.typ`, `typst.toml` declares `compiler = "0.15.1"`). It follows the *UCAS Guidelines on Writing Graduate Degree Theses (2022)* (`docs/RULES-GRAD.md`) and the *UCAS Guidelines on Writing Undergraduate Theses/Designs (2023-10)* (`docs/RULES-BACHELOR.md`). A newer local Typst CLI (e.g. 0.15.x) normally still compiles.

## Common commands

```bash
# Compile (`--root` is required, otherwise `../lib.typ` triggers a sandbox escape; `--font-path fonts` is required on machines without system CJK fonts, otherwise Chinese renders as tofu; omittable on this macOS machine, which has system Songti/Heiti)
typst compile template/thesis.typ   --root . --font-path fonts
typst compile template/proposal.typ --root . --font-path fonts
typst watch   template/thesis.typ   --root . --font-path fonts   # live preview

# Format (tool is typstyle, install via brew install typstyle or cargo install typstyle first); always run before committing
make format                 # format all .typ files
make format-main            # only lib.typ and template/thesis.typ
make format-check           # check only, no writes; enforced by CI
make format-file FILE=path/to/file.typ

# Package checks
make lint-quick             # no external index needed; checks typst.toml fields and entry point
make lint                   # needs typst/package-check (install via make lint-install, plus a local package index)
```

No test suite; "verification" means `make format-check` plus a `typst compile` that produces a PDF.

## Architecture

### Core pattern: the `documentclass` closure factory (`lib.typ`)

`documentclass(...)` is the single entry point. It takes global configuration (`doctype`/`degree`/`fontset`/`fonts`/`info`/`bibliography`/`twoside`/`anonymous`) and returns a dictionary of functions with the global configuration bound via closure. Never call a page or layout function directly; everything comes wrapped by `documentclass`. **When calling these functions, do not re-pass `fontset`/`fonts`/`info` and other closure-held parameters**. Set them once at the `documentclass` top level.

Returned functions fall into three groups: **layouts** (`doc`/`preface`/`mainmatter`/`appendix`, switched via `#show:`) / **pages** (`cover`/`decl-page`/`abstract`/`abstract-en`, dispatched by `doctype` to `master-*`/`bachelor-*`; plus `outline-page`/`list-of-figures-and-tables`/`notation`/`bilingual-bibliography`/`acknowledgement`/`backmatter`/`fonts-display-page`) / **pass-through tools** (`bifigure`/`bitable`/`continued-table`/`auto-table`/`aligned-equation`/theorem envs: `axiom`/`theorem`/`lemma`/`corollary`/`assertion`/`proposition`/`conjecture`/`definition`/`example`/`remark`/`proof`).

See `template/thesis.typ` for usage: destructure the returned dictionary, then follow the fixed order `#show: doc` → `#cover()` → `#decl-page()` → `#show: preface` → abstract / outline / list of figures and tables / notation → `#show: mainmatter` → body → `#bilingual-bibliography(full: true)` → `#show: appendix` → `#acknowledgement()` → `#backmatter()`. Preface/mainmatter/appendix switch layouts via `#show:` (page numbering, headers/footers, numbering change accordingly). Do not turn them into plain function calls; the call order mirrors the thesis's physical structure and must not be rearranged.

### Core pattern: the `proposalclass` closure factory (`lib.typ`)

`proposalclass(...)` is the entry point for research proposals (开题报告), structured like `documentclass`: important knobs first (`doctype`/`fontset`/`fonts`/`info`/`bibliography`/`cfg`), page/layout functions returned as a closed-over dictionary. User content lives only in `template/proposal.typ`; layout lives in `pages/proposal.typ`. `pages/bachelor-proposal.typ` and `pages/master-proposal.typ` are thin aliases of the shared implementation (bachelor layout currently identical to graduate; fork there later if needed).

Returned functions: `doc` (A4, Word margins), `cover`, `notice` (填表说明), `outline-page` (outline-form TOC linked to body headings), `mainmatter` (heading numbering `1.` / `1.1.` / `1.1.2`, 2em first-line indent, footer `第X页，共Y页`), `bilingual-bibliography` (`page-decoration: none`), plus figure/table helpers. `info` must fill supervisors via `supervisors-full` and/or `supervisors-split` + `supervisor-form`. Compile with `typst compile template/proposal.typ --root . --font-path fonts`.

### Layer responsibilities

- `layouts/`: page-level layouts; control page numbering, headers/footers, heading numbering.
  - `doc.typ`: global `set page` (A4, top/bottom 2.54cm, left/right 3.17cm), PDF metadata, CJK fake bold (enabled via `@preview/cuti:0.4.0`'s `show-cn-fakebold` for non-fandol fontsets; keep this `show` rule when editing `doc.typ`). The 1.5cm header/footer-to-edge distance is not in `doc.typ`; `preface.typ`/`mainmatter.typ` implement it with absolute positioning via `page.foreground` plus `place(top+center, dy:1.5cm)` / `place(bottom+center, dy:-1.5cm)`. Never use `header-ascent`/`footer-descent` here: their semantics is "amount intruding into the margin", not distance-to-edge.
  - `preface.typ`: front matter, roman page numbers.
  - `mainmatter.typ`: body, arabic page numbers, chapter numbering (`custom-numbering`, defaults `第1章` / `1.1`), 1.25× line spacing, 2em first-line indent, header shows current chapter name. Level-1 headings get `pagebreak(weak: true)` by default; to suppress it (e.g. for "致谢" continuing previous content), tag the heading `<no-auto-pagebreak>`, which `mainmatter.typ` recognizes. Heading above-spacing differs by level: L1 uses explicit `v()` (preserved after page breaks), while L2+ uses `block(above:)` (max-folds with preceding spacing, clipped at page top). See "Verified conclusions".
  - `appendix.typ`: appendix. It declares only the deltas vs. the body (unnumbered level-1 headings via `first-level: ""`, 附图/附表 prefixes, L2+ excluded from the outline, counter resets, page + header/footer). Base styling (fonts/leading/heading glyphs/figure captions/footnotes) is deliberately not repeated: in the standard order the appendix region sits inside the `#show: mainmatter` scope (nested show rules) and inherits everything automatically. Subsections `1.1`, figures/tables `1-1`, equations `(1-1)`.
- `pages/`: concrete page implementations, with `bachelor-*` / `master-*` pairs. Proposal layout is `pages/proposal.typ` (shared); `bachelor-proposal.typ` / `master-proposal.typ` re-export it.

### Key utils

- `style.typ`: `字号` (CJK size-name to pt dictionary), `字体组` (four presets `windows`/`mac`/`fandol`/`adobe`, each with 宋体/黑体/楷体/仿宋/等宽), `get-fonts(fontset)`. `documentclass`'s `fontset` selects a preset, the `fonts` dict overrides individual entries (e.g. `fonts: (楷体: (...))`); the two merge.
- `bilingual-figured.typ`: general bilingual figure/table engine. Provides `bifigure`/`bitable`/`bilingual-caption-style` plus counter-reset logic, distinguishing bilingual figure kinds via `prefixed-kind`.
- `custom-figure.typ`: in-template wrapper applying the UCAS-mandated style to the engine via `thesis-bilingual-caption-style` (宋体 五号 bold, `*注：*` prefix, `keep_together: true` against page breaks by default, outer block spacing at spec values except the English caption's `above`, which gets one extra `leading`; see "Verified conclusions"). Edit bilingual caption leading / page-break policy here.
- `continued-table.typ`: `auto-table` (auto continued tables across pages, actively breakable, unconstrained by `keep_together`, for long tables; with `landscape: true` the whole table rotates instead and is forced `breakable: false`) plus `continued-table` (manual continuation, needs the source table's label). All three of `bifigure`/`bitable`/`auto-table` take a `landscape` parameter: the first two rotate via `bilingual-figured._render-bilingual`, the last via its own logic in this file with `rotate(-90deg, reflow: true, ...)` (top-left, bottom-right orientation per spec).
- `aligned-equation.typ`: multi-line aligned equations, pure pass-through (semantic marker); bottom-aligned numbering comes from the global `set math.equation(number-align: bottom + end)` in `mainmatter`/`appendix`.
- `theorem.typ`: amsthm-style theorem environments exported via `documentclass` (`axiom`/`theorem`/`lemma`/`corollary`/`assertion`/`proposition`/`conjecture` share one counter; `definition`/`example` each have their own; `remark` unnumbered; `proof` ends with a black square). Numbers are `章-序` and reset in `mainmatter` via `reset-theorem-counters()` on level-1 headings. Refs go through `show-theorem-ref` (registered in `mainmatter`/`appendix`): plain blocks with an in-block `step()` (official counter-docs pattern, single element so trailing labels attach), never figure-wrapped (figure implicit steps double-count with show-rule rebuilds; verified by probe).

### Cross-reference conventions

Body text uniformly uses prefixed references: figures `@fig:label`, tables `@tbl:label`, display equations `@eqt:label` (`aligned-equation` likewise uses `@eqt:label`), theorems `@thm:`/`@axm:`/`@lem:`/`@cor:`/`@ast:`/`@prp:`/`@cnj:`/`@def:`/`@ex:` (one prefix per kind, see `theorem.typ` `_thm-refspec`; `ref-supplements` dict keys are the three groups `thm`/`def`/`ex`). Tag a display equation `<->` for no number. Bilingual captions go through `caption-zh`/`caption-en`, or the `caption: metadata((zh, en, none, [表], [Table]))` form (`bitable` accepts the native-`figure` metadata style).

### External dependencies

`@preview/cuti:0.4.0` (CJK fake bold, used in `doc.typ`/`master-abstract.typ`). Re-verify compatibility when upgrading this dependency or the Typst compiler version.

### Working requirements

Typst is a young language with fast-moving syntax and APIs. **Never write Typst from memory.** For syntax, function signatures, parameters, or package usage, check Context7 first:

- Syntax/function docs: `/websites/typst_app` (official live docs, freshest).
- **Do not** treat `/typst/typst` (GitHub source) release-tag snapshots as "latest". They lag; the latest version is whatever local `typst --version` or [GitHub Releases](https://github.com/typst/typst/releases) says.

## Verified conclusions (baseline: Typst 0.15.x + 2026-09 PDF; re-verify per the last bullet after upgrading the compiler)

- Nested show-rule inheritance: in the standard order, the appendix/acknowledgement/backmatter region sits inside the `#show: mainmatter` scope and automatically inherits all of its `set`/`show` rules. The leanness of `appendix.typ` is deliberate design. **Do not** add font/leading/heading styling to `appendix.typ`/`acknowledgement.typ`/`backmatter.typ` (it stacks on top of the outer rules, e.g. doubling heading spacing).
- Spacing combination rules (proven with micro-probes): `block(above/below)` max-folds with adjacent block spacing (≈ TeX `\addvspace`); explicit `v()` adds to block spacing instead of folding. Hence L2+ heading above-spacing must use `block(above:)`. **Do not** switch it back to `v()` (that produced 63.8pt chapter-to-section gaps vs. 34.8pt in the LaTeX reference; the current model gives ≈39.8pt, whose residual is the below-compensation required by the heading-to-body path).
- Leading semantics: `行距.正文 = 1.1em` (Typst `leading` is extra inter-line gap), measured body baseline distance 21.54pt ≈ LaTeX reference 21.60pt; Word's "1.25×" is nominal only (≈15pt literally), and neither side follows it literally. **Do not** write `1.25em`. Setting `spacing` equal to `leading` implements the "0pt before/after" semantics. Comparison table: `docs/CUSTOMIZE.md §8.9`.
- Outline indent: the `level` passed to the `outline(indent:)` callback is 0-based (unlike `outline.entry.level`, which is 1-based; undocumented, measured 0/12/24pt hitting "flush/one-char/two-char" exactly). The `slice(0, level+1)` logic in `outline-page.typ` is correct. **Do not** "fix" it as an off-by-one. Also: dots and `entry.page()` must stay inside the entry's `text()`; otherwise level-1 page numbers render smaller than the entry text. (2026-09 re-verification: PyMuPDF span origins x = 89.86 / 101.86 / 113.86pt = flush / +12pt / +24pt exactly.)
- Code blocks join values: a code block's value is the **join of all its expression values**, not just the last one (officially documented: Scripting > Blocks; Function). This is why `enter-appendix-mode()` as a bare statement in `appendix.typ` still works — its `state.update` content is part of the joined return value. **Do not** describe this as "discarded but effective" or treat it as undocumented behavior.
- Chinese-English caption gap: the English caption's `above` of one `leading` is intentional (baseline distance between two single-line blocks excludes `leading`); the spec's literal "0pt above for English captions" is unimplementable directly. Measured zh-to-en 18.5pt (LaTeX 21.6pt); both look fine. **Do not** change it to `0pt`.
- Equation number size: inheriting body 小四 is a known deviation (`docs/CUSTOMIZE.md §19.1`; the LaTeX reference does the same). **Do not** fix it with a `numbering` function returning `text(五号)`. Probes prove it also shrinks in-text `@eqt:` references to 五号.
- Latin font fallback is deterministic by design: every font group lists Times New Roman first, so Latin/digits/punctuation always resolve to Times; English cover and English abstract verified all-Times. **Do not** add explicit font wrappers for this.
- Bachelor-vs-graduate split (measured 2026-09 on built PDFs; table in `docs/CUSTOMIZE.md §1.1`): bachelor cover info rows use the Word reading of "2 倍行距" (Chinese 2.5em → measured 34.3–35.4pt vs the official sample's 34.95pt; English 2.3em → 32.17pt vs the undergraduate Word sample's ≈32.8pt), while the graduate covers keep the original 1em-gutter / `行距.正文` rhythm (27.69pt, matching the LaTeX sample's 26.88pt and required so the trailing date stays inside the text block). Bachelor headings/outline/running head compensate Typst's undocumented 0.3em post-numbering gap (`suffix: h(-编号自动间隙)` plus two compensating consumers) to land exactly 1em; the graduate numbering keeps 1.3em. Bachelor page numbers are flush with the text block (even x0 = 89.86, odd x1 = 505.42) and the bachelor header rule spans the text block (415.56pt); both stay as-is for graduate. Bachelor footnotes are circled ①–⑩ with a synthesized 0.7em superscript (macOS Songti/Kaiti/FangSong map circled digits in their `sups` tables to ~0.1em micro-glyphs; ①–⑩ exist in all CJK font groups, ⑪–⑳ are missing from Songti/FangZheng/Fandol). **Do not** "unify" these with the graduate path — graduate styling is frozen.
- Layout verification method: after `make format-check` plus compiling to PDF, measure baselines via span `origin` with PyMuPDF (`fitz`, available on this machine) and compare against the `docs/CUSTOMIZE.md §8.9` table; the LaTeX reference numbers are archived, so recompiling LaTeX is usually unnecessary (that requires a batch of `--usermode` packages plus `fontset=fandol`; see the audit record).
- Validity period: the above conclusions depend on three current-Typst behaviors: `block`/`v` folding semantics, the 0-based `outline(indent:)` level, and `math.equation` having no independent number styling. After bumping `compiler` in `typst.toml`, re-run the measurements above before touching code.
- Upgrade regression checklist (beyond the validity period above; 2026-09 audit):
  1. `bilingual-bibliography` hangs its zh↔en transforms on `grid.cell.where(x: 1)`, which relies on the undocumented internal grid layout of `bibliography` (not a public API). After a compiler upgrade, visually check English entries for leftover 等/译/卷/版; regression test: `typst compile tests/bilingual-transform.typ --root .` (see `utils/bilingual-bibliography.typ` header).
  2. `outline.indent` callback argument type (see the outline-indent conclusion above).
  3. Programmatic duplicate labels (unnumbered equations all get `eqt:bilingual-figured-no-label`) currently emit no warnings; re-check if a future Typst starts warning.
  4. Bachelor number-to-title distance: expect exactly 1em (14.0pt at 四号, 12.0pt at 小四, 9.0pt in the running head). If Typst changes or removes its automatic 0.3em post-numbering gap, update `编号自动间隙` and the outline `gap`, then re-run the pre/post graduate comparison.
  5. Bachelor circled footnote markers: measure the in-text marker ink height at a 12pt body (expect ≈7.8pt at 0.7em). If a future Typst changes `super`'s handling of `size`, re-check that ① is not rendered as a micro-glyph.

## Boundaries & red lines

- **Bachelor styles only**: changes must not affect graduate (master/doctor) output. Every bachelor-vs-graduate difference is gated on `doctype`, with the graduate branch preserving the original code path verbatim (`layouts/doc.typ`, `layouts/mainmatter.typ`, `layouts/appendix.typ`, `layouts/preface.typ`, `utils/page-foreground.typ`, `utils/bilingual-bibliography.typ`, `pages/acknowledgement.typ`, `pages/backmatter.typ`, `pages/outline-page.typ`, `pages/list-of-figures-and-tables.typ`, `pages/notation.typ`; each takes an additive `doctype: "doctor"` parameter that `lib.typ` fills in). **Verify after every change**: materialize the pre-change tree (`rm -rf /tmp/pre && mkdir -p /tmp/pre && git archive HEAD | tar -x -C /tmp/pre && git checkout-index -a --prefix=/tmp/pre/`), compile `template/thesis.typ` in both trees, and diff every page's text spans (position/size/font/text) plus vector drawings with PyMuPDF — expect zero differing pages.
- Typst scripting traps when gating: a `set` rule inside an `if`-block affects **only content in the same block** (measured), so write `if bachelor { set x(..); content } else { content }` — never `if bachelor { set x(..) }` with the content outside; and **parameter defaults cannot reference other parameters** (`#let f(a: 1, b: a)` → "unknown variable: a"), so resolve doctype-dependent defaults in the function body via an `auto` sentinel (as `mainmatter`/`appendix` do for `numbering`).
- Proposals (`template/proposal.typ` + `pages/proposal.typ` + `proposalclass`): independent of the thesis `documentclass` body layouts, but **reuse** `utils/style.typ`, `utils/bilingual-bibliography.typ` (`page-decoration: none`), and the figure/table helpers. Bachelor proposal layout is intentionally identical to graduate for now — do not fork styles unless asked. Heading numbering for proposals is `1.` / `1.1.` / `1.1.2` (not `第1章`); body paragraphs always get 2em first-line indent. Supervisors are **required** in `info`: fill `supervisors-full` and/or `supervisors-split`; `supervisor-form` is `auto` (detect from what was filled; both filled → prefer full row + non-fatal warning state) | `"full"` | `"split"` (locked form; wrong combination panics).
- `fonts/`: only README and subdirectory placeholders. **Never commit font files** (licensing; see `fonts/README.md` and `docs/LOGO_COPYRIGHT.md`). Local builds must use `--font-path fonts` pointing at user-supplied fonts.
- `assets/vi/`: UCAS visual-identity assets belong to the university; personal-thesis fair use only, no commercial use.
- `.env`: gitignored and contains secrets. Never commit it, never write it into docs.

## Repo conventions

- Main branch `main`, plus a long-lived `style` branch. Commit messages follow the existing gitmoji style (`feat(utils): ✨ ...`, `fix(layouts): 🐛 ...`, `docs(docs): 📝 ...`).
- `.editorconfig`: 2-space indent for `.typ`, tabs for `Makefile`, 4 spaces for `.sh`, no trailing-whitespace trimming for `.md`.
- `template/thesis.pdf` / `template/proposal.pdf` are gitignored and regenerable; they are deleted by `make clean` too, because a leftover copy makes `make lint` (typst-package-check) fail with `files/compilation-artifact`. Run lint on a freshly cleaned tree.

## Mode switches

- `twoside: true`: duplex printing, auto-inserts blank pages so each part starts on an odd (right-hand) page.
- `anonymous: true`: blind-review mode, hides author/supervisor identity info.
- `degree: "academic" | "professional"`: academic vs. professional degree; affects the degree-category display on the cover and abstract.
