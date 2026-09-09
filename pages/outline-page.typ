#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground

// 目录生成
#let outline-page(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  depth: 3,
  title: [目#h(1em)录],
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: (字号.四号, 字号.小四),
  // 段前段后间距规范值
  // 一级：段前6pt，段后0pt
  // 二级/三级：段前6pt，段后0pt
  above: (6pt, 6pt),
  below: (0pt, 0pt),
  indent: (0pt, 12pt, 12pt),
  // 全都显示点号
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  // 字体与字号
  if font == auto {
    font = (fonts.黑体, fonts.黑体)
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

  // 条目字号（含点线与页码，见 show outline.entry 内 text()）由各级 size 落实，
  // 此处不再设全局字号
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

  // 目录样式
  set outline(indent: level => indent
    .slice(0, calc.min(level + 1, indent.len()))
    .sum())
  show outline.entry: entry => {
    // 条目单倍行距（规范值；多行条目才显现差异）
    set par(leading: 行距.单倍, spacing: 0pt)
    // 获取当前级别字体大小
    let current-size = size.at(entry.level - 1, default: size.last())
    // 获取当前级别规范值
    let current-above = above.at(entry.level - 1, default: above.last())
    let current-below = below.at(entry.level - 1, default: below.last())
    // 段前段后间距取规范值。block.above/below 与 par.spacing 取 max 不叠加，
    // 无需为行距额外补偿（与 mainmatter 标题间距同源修正）。
    let actual-above = current-above
    let actual-below = current-below
    block(
      above: actual-above,
      below: actual-below,
      link(entry.element.location(), entry.indented(
        none,
        {
          // 点线与页码置于同字号 text 内：整行统一为条目字号（一级四号，
          // 二三级小四；数字走字体表的 Times 回退），与 LaTeX 参考实现
          // （\@pnumwidth 框内 \normalfont 继承条目字号）一致。
          // 若置于 text 之外，页码将继承外层小四，一级条目会出现
          // 14pt 标题配 12pt 页码的不一致。
          text(
            font: font.at(entry.level - 1, default: font.last()),
            size: current-size,
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
              box(width: 1fr, inset: (x: .25em), fill.at(
                entry.level - 1,
                default: fill.last(),
              ))
              entry.page()
            },
          )
        },
        gap: 0pt,
      )),
    )
  }

  // 显示目录
  outline(title: none, depth: depth)

  // 结尾重置页面样式：function 体内的 set page 会泄漏到后续文档流，此处显式
  // 清除，使后续换页产生的填充页不残留本部分样式；标准组装顺序下由下一部分
  // 起始的页面样式覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
