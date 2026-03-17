#import "bilingual-figured.typ"
#import "style.typ": 字号

#let bifigure = bilingual-figured.bifigure
#let bitable = bilingual-figured.bitable

#let thesis-bilingual-caption-style(
  fonts,
  leading: 1.25em,
  keep_together: true,
  caption_par: auto,
  note_par: auto,
  zh_block: auto,
  en_block: auto,
  note_block: auto,
  note_inset: (left: 2em),
) = {
  let cap-par = if caption_par == auto {
    (leading: leading)
  } else {
    caption_par
  }
  let note-par = if note_par == auto {
    cap-par
  } else {
    note_par
  }
  let zh = if zh_block == auto {
    (above: 6pt + leading, below: 0pt + leading)
  } else {
    zh_block
  }
  let en = if en_block == auto {
    (above: 0pt + leading, below: 12pt)
  } else {
    en_block
  }
  let note = if note_block == auto {
    (above: 6pt + leading, below: 0pt + leading, inset: note_inset)
  } else if "inset" in note_block {
    note_block
  } else {
    note_block + (inset: note_inset)
  }

  bilingual-figured.bilingual-caption-style(
    caption_par: cap-par,
    note_par: note-par,
    zh_text: (font: fonts.宋体, size: 字号.五号, weight: "bold"),
    en_text: (font: fonts.宋体, size: 字号.五号, weight: "bold"),
    note_text: (font: fonts.宋体, size: 字号.五号),
    note_prefix: [*注：* ],
    note_align: left,
    zh_block: zh,
    en_block: en,
    note_block: note,
    keep_together: keep_together,
    float_clearance: 1.5em,
    float_align: center,
    float_width: 100%,
  )
}

#let _thesis-style(fonts) = thesis-bilingual-caption-style(fonts)

#let show-bifigure(fonts, kind: "bifigure") = it => bilingual-figured.show-bifigure(
  it,
  kind: kind,
  style: _thesis-style(fonts),
)

#let show-bitable(fonts, kind: "bitable") = it => bilingual-figured.show-bitable(
  it,
  kind: kind,
  style: _thesis-style(fonts),
)

#let show-bilingual-outline-entry(_fonts) = it => bilingual-figured.show-bilingual-outline-entry(
  it,
)

#let bilingual-figure-rules(fonts) = {
  let style = _thesis-style(fonts)
  show figure: bilingual-figured.show-bilingual.with(
    figure_style: style,
    table_style: style,
  )
  show outline.entry.where(level: 1): show-bilingual-outline-entry(fonts)
}
