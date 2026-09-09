#import "../utils/bilingual-figured.typ"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground

// 图表目录
#let list-of-figures-and-tables(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
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
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  if font == auto {
    font = fonts.黑体
  }

  // 2.  正式渲染：先设置页眉页脚（page.foreground）再换页，使双面模式下
  // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
  // 奇数页章名/部分名，页码罗马数字居中）。全静态实现，无运行时判断。
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  // 图表目录（不显示）
  invisible-heading(level: 1, outlined: outlined, title)

  v(title-above)
  // 插图目录标题（单倍行距）
  {
    set align(center)
    set par(leading: 行距.单倍, spacing: 0pt)
    text(..title-text-args, fig-title)
  }

  v(title-below)

  // 段前段后取规范值：相邻 block 间距取 max 不叠加，
  // 行距由 leading 提供，勿再叠加字号。
  let actual-above = above
  let actual-below = below

  // 自定义 outline entry：双语图表目录仅显示中文标题
  show outline.entry: it => {
    // 条目单倍行距（规范值；多行条目才显现差异）
    set par(leading: 行距.单倍, spacing: 0pt)
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
      bilingual-figured
        .show-bilingual-outline-entry
        .with(
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

  // 表格目录标题（单倍行距）
  {
    set align(center)
    set par(leading: 行距.单倍, spacing: 0pt)
    text(..title-text-args, tbl-title)
  }

  v(title-below)

  // 渲染表目录
  bilingual-figured.outline(target-kind: "bitable", title: none)

  // 结尾重置页面样式：function 体内的 set page 会泄漏到后续文档流，此处显式
  // 清除，使后续换页产生的填充页不残留本部分样式（本页已有样式不受影响）；
  // 标准组装顺序下由下一部分起始的页面样式覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
