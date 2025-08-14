#import "@preview/i-figured:0.2.4"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": get-fonts, 字号

// 图表目录
#let list-of-figures-and-tables(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  // 其他参数
  title: "图表目录", // 不显示
  fig-title: "图目录",
  tbl-title: "表目录",
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.四号,
  // 条目垂直间距
  above: 14pt,
  below: 14pt,
  ..args,
) = {
  // 1. 默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  if font == auto {
    font = fonts.黑体
  }

  // 2. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  // 图表目录（不显示）
  invisible-heading(level: 1, outlined: outlined, title)

  v(title-above)
  // ——— 插图目录标题 ———
  {
    set align(center)
    text(..title-text-args, fig-title)
  }

  v(title-below)

  show outline.entry: set block(
    above: above,
    below: below,
  )

  // 先渲染图目录
  i-figured.outline(target-kind: image, title: none)

  v(title-above)

  // ——— 表格目录标题 ———
  {
    set align(center)
    text(..title-text-args, tbl-title)
  }


  v(title-below)

  // 紧接着渲染表目录
  i-figured.outline(target-kind: table, title: none)

  // 手动分页：若需要单双面排版，章节结束后对齐到奇数页
  if twoside {
    pagebreak() + " "
  }
}
