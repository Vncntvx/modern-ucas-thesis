#import "../utils/bilingual-figured.typ"
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
  // 段前段后间距规范值
  above: 6pt,
  below: 0pt,
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

  // 计算段前段后间距：规范值 + 单倍行距（字体大小）
  // 段前不加行距，优化视觉效果 (不知道为什么，不去除会导致间距过大)
  let actual-above = above
  let actual-below = below + size

  // 自定义 outline entry：双语图表目录仅显示中文标题
  show outline.entry: it => {
    let fig = it.element
    let kind = if fig != none and type(fig) == content and fig.has("kind") {
      fig.kind
    } else {
      none
    }
    let is-bilingual = (
      bilingual-figured.is-kind(kind, "bifigure")
        or bilingual-figured.is-kind(kind, "bitable")
    )

    if is-bilingual {
      bilingual-figured.show-bilingual-outline-entry.with(
        lang: "zh",
        above: actual-above,
        below: actual-below,
      )(it)
    } else {
      it
    }
  }

  // 渲染图目录
  bilingual-figured.outline(target-kind: "bifigure", title: none)

  v(title-above)

  // ——— 表格目录标题 ———
  {
    set align(center)
    text(..title-text-args, tbl-title)
  }

  v(title-below)

  // 渲染表目录
  bilingual-figured.outline(target-kind: "bitable", title: none)

  // 手动分页：若需要单双面排版，章节结束后对齐到奇数页
  if twoside {
    pagebreak() + " "
  }
}
