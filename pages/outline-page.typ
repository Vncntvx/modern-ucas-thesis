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
  // 文档类型："bachelor" 启用本科规范差异（页眉分隔线约束到版心宽）；
  // 默认 "doctor" 为研究生版式。
  doctype: "doctor",
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
  // 点线：半角句点密排；页码与点线在兄弟 text 内固定 Times 小四
  fill: (repeat([.], gap: 0.12em),),
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
    foreground: preface-foreground(
      info: info,
      fonts: fonts,
      doctype: doctype,
    ),
  )
  pagebreak(weak: true, to: if twoside { "odd" })

  // 条目字号（含题名）由各级 size 落实；点线与页码见 show outline.entry 内兄弟 text
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
    let current-size = size.at(entry.level - 1, default: size.last())
    let current-above = above.at(entry.level - 1, default: above.last())
    let current-below = below.at(entry.level - 1, default: below.last())
    let current-font = font.at(entry.level - 1, default: font.last())
    // fill 可为 content 或 per-level 数组（与 outline-page 的 fill 参数兼容）
    let current-fill = if type(fill) == array {
      fill.at(entry.level - 1, default: fill.last())
    } else {
      fill
    }
    block(
      above: current-above,
      below: current-below,
      link(entry.element.location(), entry.indented(
        none,
        {
          // 序号 + 题名按条目字号；点线与页码为紧随其后的兄弟 text（Times 小四）
          // —— 勿嵌进题名 text，否则多行一级条目行盒高度会变
          // （有意不随一级四号变化，见 AGENTS.md / CUSTOMIZE §5.3）
          text(
            font: current-font,
            size: current-size,
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          text(font: ("Times New Roman",), size: 字号.小四, {
            box(width: 1fr, inset: (x: .25em), current-fill)
            entry.page()
          })
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
