#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/invisible-heading.typ": invisible-heading
#import "@preview/cuti:0.4.0": fakebold

// 研究生中文摘要页
#let master-abstract(
  // documentclass 传入参数
  doctype: "master",
  degree: "academic",
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
  abstract-title-weight: "regular",
  stroke-width: 0.5pt,
  info-value-align: center,
  info-inset: (x: 0pt, bottom: 0pt),
  info-key-width: 74pt,
  grid-inset: 0pt,
  column-gutter: 0pt,
  row-gutter: 10pt,
  anonymous-info-keys: ("author", "grade", "supervisors"),
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
      grade: "20XX",
      department: "某学院",
      major: "某专业",
      supervisors: (
        (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
      ),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  内置辅助函数
  let info-key(body) = {
    rect(inset: info-inset, stroke: none, text(
      font: fonts.楷体,
      size: 字号.四号,
      body,
    ))
  }

  let info-value(key, body) = {
    set align(info-value-align)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stroke-width + black),
      text(
        font: fonts.楷体,
        size: 字号.四号,
        bottom-edge: "descender",
        if (anonymous and (key in anonymous-info-keys)) {
          "█████"
        } else {
          body
        },
      ),
    )
  }

  // 4.  正式渲染
  // 起始页面样式：先设置页眉页脚（page.foreground）再换页，使双面模式下
  // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
  // 奇数页章名/部分名，页码罗马数字居中）。全静态实现，无运行时判断。
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    #set par(spacing: spacing)

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
        strong[摘#h(1em)要],
      ))
    ]

    #v(title-below)

    #[#set text(font: fonts.宋体, size: 字号.小四)
      #set par(first-line-indent: (amount: 2em, all: true))

      #body
    ]

    // 关键词与摘要间空一行：一行高度 = 正文基线距 21.6pt
    #v(21.6pt)

    #[
      #set text(font: fonts.宋体, size: 字号.小四)
      #fakebold[关键词：]#(keywords.intersperse("，")).sum()
    ]

  ]

  // 结尾重置页面样式：function 体内的 set page 会泄漏到后续文档流，此处显式
  // 清除，使后续换页产生的填充页不残留本部分样式；标准组装顺序下由下一部分
  // 起始的页面样式覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
