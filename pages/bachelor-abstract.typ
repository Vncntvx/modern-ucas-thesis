#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/invisible-heading.typ": invisible-heading
#import "@preview/cuti:0.4.0": fakebold

// 本科生中文摘要页
//
// 依据《本科生撰写规范》三·（三）摘要和关键词（与研究生要求一致）：
// - 标题"摘 要"（二字间空一个汉字符位）黑体四号加粗居中，单倍行距，段前 24 磅、段后 18 磅；
// - 正文宋体小四号，1.25 倍行距，段前段后 0 磅；
// - 关键词与摘要间空一行，"关键词"三字加粗，另起一行左顶格、中文逗号分隔；
// - 摘要另起一页，与正文前内容连续编页（罗马数字）。
#let bachelor-abstract(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: [摘#h(1em)要],
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  // 标题字重：规范要求加粗；CJK 字体无粗体时由 cuti 伪加粗。
  abstract-title-weight: "bold",
  // 1.25 倍行距：Typst leading 是行盒之间的额外间隙，取 行距.正文，勿写 1.25em。
  leading: 行距.正文,
  // 段前段后 0 磅：段间距不含行距，取与 leading 等值，使段间基线距与行内一致。
  spacing: 行距.正文,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisors: (
        (name: "李四", title: "教授", affiliation: ""),
      ),
    )
      + info
  )

  // 2.  正式渲染：先设置页眉页脚（page.foreground）再换页，使双面模式下
  // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
  // 奇数页部分名，页码罗马数字居中）。全静态实现，无运行时判断。
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(
      info: info,
      fonts: fonts,
      doctype: "bachelor",
    ),
  )
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true, spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #v(title-above)

    // 标题单倍行距：作用域内覆盖页面级的 1.25 倍行距
    #[
      #set par(leading: 行距.单倍, spacing: 0pt)
      #align(center, text(
        font: fonts.黑体,
        size: 字号.四号,
        weight: abstract-title-weight,
        [摘#h(1em)要],
      ))
    ]

    #v(title-below)

    // 正文字体/行距继承自页面作用域（宋体小四），此处仅追加首行缩进。
    #[
      #set par(first-line-indent: (amount: 2em, all: true))

      #body
    ]

    // 关键词与摘要间空一行：一行高度 = 正文基线距 21.6pt
    #v(21.6pt)

    // 字体继承自页面作用域，无需重复 set text。
    #[#fakebold[关键词：]#(keywords.intersperse("，")).sum()]
  ]

  // 结尾重置页面样式：function 体内的 set page 会泄漏到后续文档流，此处显式
  // 清除，使后续换页产生的填充页不残留本部分样式；标准组装顺序下由下一部分
  // 起始的页面样式覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
