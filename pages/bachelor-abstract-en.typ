#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/supervisor.typ": normalize-supervisors

// 本科生英文摘要页
#let bachelor-abstract-en(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: false,
  anonymous-info-keys: ("author-en", "supervisors-en"),
  // 1.25 倍行距：Typst leading 是行盒之间的额外间隙，取 行距.正文，勿写 1.25em。
  // 段前段后 0 磅：段间距不含行距，取与 leading 等值，使段间基线距与行内一致。
  leading: 行距.正文,
  spacing: 行距.正文,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title-en: "UCAS Thesis Template for Typst",
      author-en: "Zhang San",
      department-en: "XX Department",
      major-en: "XX Major",
      supervisors-en: (
        (name: "Si Li", title: "Professor", affiliation: ""),
      ),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 2.2 导师信息归一化为字典列表
  info.supervisors-en = normalize-supervisors(info.supervisors-en)

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if (not anonymous or (key not in anonymous-info-keys)) {
      body
    }
  }

  // 4.  正式渲染
  [
    // 起始页面样式：先设置页眉页脚（page.foreground）再换页，使双面模式下
    // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
    // 奇数页章名/部分名，页码罗马数字居中）。全静态实现，无运行时判断。
    #set page(
      numbering: "I",
      footer: none,
      foreground: preface-foreground(info: info, fonts: fonts),
    )
    #pagebreak(weak: true, to: if twoside { "odd" })

    #set text(font: fonts.楷体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    #set par(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(size: 字号.小二, weight: "bold")

      // 页首空一行：一行高度 = 正文基线距 21.6pt
      #v(21.6pt)

      #double-underline[*中国科学院大学本科生毕业论文（设计、作品）英文摘要*]
    ]

    #v(2pt)

    THESIS: #info-value("title-en", (("",) + info.title-en).sum())

    DEPARTMENT: #info-value("department-en", info.department-en)

    SPECIALIZATION: #info-value("major-en", info.major-en)

    UNDERGRADUATE: #info-value("author-en", info.author-en)

    MENTOR: #info-value(
      "supervisors-en",
      info.supervisors-en.map(s => {
        // 英文习惯职称在前（如 "Professor Si Li"），与英文封面一致
        (s.at("title", default: ""), s.at("name", default: "")).filter(x => x != "").join(" ")
      }).filter(s => s != "").join(", "),
    )

    ABSTRACT: #body

    #v(1em)

    #strong[Key Words:] #(("",) + keywords.intersperse(", ")).sum()
  ]

  // 结尾重置页面样式：function 体内的 set page 会泄漏到后续文档流，此处显式
  // 清除，使后续换页产生的填充页不残留本部分样式；标准组装顺序下由下一部分
  // 起始的页面样式覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
