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
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: 字号.小四,
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
  ..args,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  // 字体与字号
  if font == auto {
    font = (fonts.黑体, fonts.黑体)
  }

  // 2. 正式渲染：起始三件套（P30）——先清样式（填充页干净），
  // 再换页（双面须奇数页起），最后重申前言域样式。全静态。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )

  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

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
          text(
            font: font.at(entry.level - 1, default: font.last()),
            size: current-size,
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          box(width: 1fr, inset: (x: .25em), fill.at(
            entry.level - 1,
            default: fill.last(),
          ))
          entry.page()
        },
        gap: 0pt,
      )),
    )
  }

  // 显示目录
  outline(title: none, depth: depth)

  // 结尾 reset（P30）：覆盖后续自定义组装顺序下可能出现的填充页；
  // 标准顺序下由下一部分起始 reset 覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
