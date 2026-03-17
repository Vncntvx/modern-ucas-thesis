/*
Copyright (c) 2023 RubixDev <silas.groh@t-online.de>
Copyright (c) 2026 modern-ucas-thesis contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#let _prefix = "bilingual-figured-"

#let prefixed-kind(kind) = {
  if type(kind) == str {
    _prefix + kind
  } else {
    _prefix + repr(kind)
  }
}

#let is-kind(kind-value, kind) = {
  type(kind-value) == str and (
    kind-value == kind or kind-value == prefixed-kind(kind)
  )
}

#let is-prefixed-kind(kind-value, kind) = {
  type(kind-value) == str and kind-value == prefixed-kind(kind)
}

#let reset-counters(
  it,
  level: 1,
  extra-kinds: (),
  include_bilingual_kinds: true,
  equations: true,
  return-orig-heading: true,
) = {
  if it.level <= level {
    let default-extra = if include_bilingual_kinds {
      ("bifigure", "bitable")
    } else {
      ()
    }
    for kind in (image, table, raw) + default-extra + extra-kinds {
      counter(figure.where(kind: prefixed-kind(kind))).update(0)
    }
    if equations {
      counter(math.equation).update(0)
    }
  }
  if return-orig-heading {
    it
  }
}

#let _typst-numbering = numbering
#let _prepare-dict(it, level, zero-fill, leading-zero, numbering) = {
  let numbers = counter(heading).at(it.location())
  while zero-fill and numbers.len() < level { numbers.push(0) }
  if numbers.len() > level { numbers = numbers.slice(0, level) }
  if not leading-zero and numbers.at(0, default: none) == 0 {
    numbers = numbers.slice(1)
  }

  let dic = it.fields()
  let _ = if "body" in dic { dic.remove("body") }
  let _ = if "label" in dic { dic.remove("label") }
  let _ = if "counter" in dic { dic.remove("counter") }
  dic + (numbering: n => _typst-numbering(numbering, ..numbers, n))
}

#let show-figure(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "1-1",
  extra-prefixes: (:),
  fallback-prefix: "fig:",
) = {
  if type(it.kind) == str and it.kind.starts-with(_prefix) {
    it
  } else {
    let figure = figure(
      it.body,
      .._prepare-dict(it, level, zero-fill, leading-zero, numbering),
      kind: prefixed-kind(it.kind),
    )
    if it.has("label") {
      let kind-key = if type(it.kind) == str { it.kind } else { repr(it.kind) }
      let prefixes = (
        table: "tbl:",
        raw: "lst:",
        bitable: "tbl:",
        bifigure: "fig:",
      ) + extra-prefixes
      let label-text = str(it.label)
      let prefix = prefixes.at(kind-key, default: fallback-prefix)
      let new-label = label(if label-text.starts-with(prefix) {
        label-text
      } else {
        prefix + label-text
      })
      [#figure #new-label]
    } else {
      figure
    }
  }
}

#let show-equation(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "(1-1)",
  supplement: none,
  prefix: "eqt:",
  only-labeled: false,
  unnumbered-label: "-",
) = {
  if (
    only-labeled and not it.has("label")
    or it.has("label") and (
      str(it.label).starts-with(prefix)
      or str(it.label) == unnumbered-label
    )
    or not it.block
  ) {
    it
  } else {
    let equation-fields = _prepare-dict(
      it,
      level,
      zero-fill,
      leading-zero,
      numbering,
    )
    let equation-fields = if supplement == auto {
      equation-fields
    } else {
      equation-fields + (supplement: supplement)
    }
    let equation = math.equation(
      it.body,
      ..equation-fields,
    )
    if it.has("label") {
      let new-label = label(prefix + str(it.label))
      [#equation #new-label]
    } else {
      let new-label = label(prefix + _prefix + "no-label")
      [#equation #new-label]
    }
  }
}

#let _typst-outline = outline
#let outline(target-kind: image, title: [List of Figures], ..args) = {
  _typst-outline(
    ..args,
    title: title,
    target: figure.where(kind: prefixed-kind(target-kind)),
  )
}

#let display-figure-number(fig) = {
  let numbers = fig.counter.at(fig.location())
  _typst-numbering(fig.numbering, ..numbers)
}

#let _default-supplements(kind) = if is-kind(kind, "bitable") {
  (zh: [表], en: [Table])
} else {
  (zh: [图], en: [Figure])
}

#let _bilingual-caption-data(
  caption-zh,
  caption-en,
  note,
  supplement-zh,
  supplement-en,
) = (
  zh: caption-zh,
  en: caption-en,
  note: note,
  supplement_zh: supplement-zh,
  supplement_en: supplement-en,
)

#let extract-bilingual-caption(fig) = {
  if fig == none or type(fig) != content or not fig.has("caption") {
    none
  } else {
    let caption = fig.caption
    if caption == none or not caption.has("body") or caption.body == none {
      none
    } else {
      let body = caption.body
      let is-meta = (
        type(body) == metadata
          or (type(body) == content and body.has("value"))
      )
      if not is-meta {
        none
      } else {
        let value = body.value
        let default-supp = _default-supplements(if fig.has("kind") {
          fig.kind
        } else {
          none
        })
        if type(value) == dictionary {
          let zh = value.at("zh", default: value.at("caption_zh", default: none))
          if zh == none {
            none
          } else {
            (
              zh: zh,
              en: value.at("en", default: value.at("caption_en", default: none)),
              note: value.at("note", default: none),
              supplement_zh: value.at(
                "supplement_zh",
                default: default-supp.zh,
              ),
              supplement_en: value.at(
                "supplement_en",
                default: default-supp.en,
              ),
            )
          }
        } else if type(value) == array and value.len() >= 1 {
          (
            zh: value.at(0, default: none),
            en: value.at(1, default: none),
            note: value.at(2, default: none),
            supplement_zh: value.at(3, default: default-supp.zh),
            supplement_en: value.at(4, default: default-supp.en),
          )
        } else {
          none
        }
      }
    }
  }
}

#let bifigure(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bifigure",
  supplement-zh: [图],
  supplement-en: [Figure],
  numbering: "1-1",
  ..args,
) = {
  figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata(_bilingual-caption-data(
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
    )),
    numbering: numbering,
    ..args,
  )
}

#let bitable(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bitable",
  supplement-zh: [表],
  supplement-en: [Table],
  numbering: "1-1",
  ..args,
) = {
  figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata(_bilingual-caption-data(
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
    )),
    numbering: numbering,
    ..args,
  )
}

#let bilingual-caption-style(
  separator: h(1em),
  caption_align: center,
  caption_par: (:),
  note_par: auto,
  zh_text: (weight: "bold"),
  en_text: (:),
  note_text: (:),
  note_prefix: [注：],
  note_align: left,
  zh_block: (above: 6pt, below: 0pt),
  en_block: (above: 0pt, below: 12pt),
  note_block: (above: 6pt, below: 0pt),
  keep_together: true,
  float_clearance: 1.5em,
  float_align: center,
  float_width: 100%,
) = (
  separator: separator,
  caption_align: caption_align,
  caption_par: caption_par,
  note_par: note_par,
  zh_text: zh_text,
  en_text: en_text,
  note_text: note_text,
  note_prefix: note_prefix,
  note_align: note_align,
  zh_block: zh_block,
  en_block: en_block,
  note_block: note_block,
  keep_together: keep_together,
  float_clearance: float_clearance,
  float_align: float_align,
  float_width: float_width,
)

#let _default-bilingual-style = bilingual-caption-style()

#let _render-bilingual-caption(data, number, style) = {
  let zh-block = style.zh_block
  let en-block = style.en_block
  [
    #set align(style.caption_align)
    #if style.caption_par != none and style.caption_par != (:) {
      set par(..style.caption_par)
    }
    #set text(..style.zh_text)
    #block(..zh-block)[
      #data.supplement_zh #number #style.separator #data.zh
    ]
    #if data.en != none {
      set text(..style.en_text)
      block(..en-block)[
        #data.supplement_en #number #style.separator #data.en
      ]
    }
  ]
}

#let _render-bilingual-note(data, style) = if data.note == none {
  []
} else {
  let note-par = if style.note_par == auto {
    style.caption_par
  } else {
    style.note_par
  }
  let note-block = style.note_block
  [
    #set align(style.note_align)
    #if note-par != none and note-par != (:) {
      set par(..note-par)
    }
    #set text(..style.note_text)
    #block(..note-block)[
      #style.note_prefix #data.note
    ]
  ]
}

#let _render-bilingual(it, kind, style: (:), title_on_top: false) = {
  let data = extract-bilingual-caption(it)
  if data == none or data.zh == none {
    it
  } else {
    let merged-style = _default-bilingual-style + style
    let number = it.counter.display(it.numbering)
    let title = _render-bilingual-caption(data, number, merged-style)
    let note = _render-bilingual-note(data, merged-style)
    let stacked = if title_on_top {
      [#title #it.body #note]
    } else {
      [#it.body #title #note]
    }
    let rendered = if merged-style.keep_together {
      block(breakable: false, stacked)
    } else {
      stacked
    }

    if it.placement != none {
      place(it.placement, float: true, clearance: merged-style.float_clearance)[
        #align(
          merged-style.float_align,
          block(width: merged-style.float_width, rendered),
        )
      ]
    } else {
      rendered
    }
  }
}

#let show-bifigure(it, style: (:), kind: "bifigure") = {
  if is-kind(it.kind, kind) {
    _render-bilingual(
      it,
      kind,
      style: style,
      title_on_top: false,
    )
  } else {
    it
  }
}

#let show-bitable(it, style: (:), kind: "bitable") = {
  if is-kind(it.kind, kind) {
    _render-bilingual(
      it,
      kind,
      style: style,
      title_on_top: true,
    )
  } else {
    it
  }
}

#let show-bilingual(
  it,
  figure_style: (:),
  table_style: (:),
  figure_kind: "bifigure",
  table_kind: "bitable",
) = {
  if is-prefixed-kind(it.kind, figure_kind) {
    _render-bilingual(
      it,
      figure_kind,
      style: figure_style,
      title_on_top: false,
    )
  } else if is-prefixed-kind(it.kind, table_kind) {
    _render-bilingual(
      it,
      table_kind,
      style: table_style,
      title_on_top: true,
    )
  } else {
    it
  }
}

#let show-bilingual-outline-entry(
  it,
  lang: "zh",
  separator: h(1em),
  above: 0pt,
  below: 0pt,
  gap: 0pt,
  link_entries: true,
) = {
  let fig = it.element
  let data = extract-bilingual-caption(fig)
  if data == none or data.zh == none {
    it
  } else {
    let use-en = lang == "en" and data.en != none
    let supplement = if use-en { data.supplement_en } else { data.supplement_zh }
    let title = if use-en { data.en } else { data.zh }
    let number = display-figure-number(fig)
    let row = it.indented(
      none,
      {
        [#supplement #number #separator #title]
        box(width: 1fr, it.fill)
        it.page()
      },
      gap: gap,
    )
    block(above: above, below: below)[
      #if link_entries {
        link(fig.location(), row)
      } else {
        row
      }
    ]
  }
}
