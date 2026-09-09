#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/invisible-heading.typ": invisible-heading

// 符号列表页
#let notation(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  title: "符号列表",
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.小四,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }

  // 字体与字号
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

  v(title-above)
  {
    set align(center)
    // 标题单倍行距
    set par(leading: 行距.单倍, spacing: 0pt)
    text(..title-text-args, title)

    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-below)

  // 设置首行缩进为 0
  set par(first-line-indent: (amount: 0pt, all: true))

  [
    #body
  ]

  // 结尾重置页面样式：function 体内的 set page 只对其后内容生效（本页已有
  // 样式不受影响），但会泄漏到后续文档流；此处显式清除，使正文 mainmatter
  // 起始换页产生的填充页不残留本部分样式。正文另页开始由 mainmatter 起始
  // 换页保证，此处不再手动分页。
  set page(numbering: none, foreground: none)
}
