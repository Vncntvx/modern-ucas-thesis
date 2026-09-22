// 研究生/本科生学位论文开题报告（中国科学院大学）
// 版式实现与内容分离：本文件只提供页面函数与默认版面参数，
// 用户配置与正文见 template/proposal.typ，由 lib.typ 的 proposalclass 注入。

#import "../utils/style.typ": get-fonts, 字号, 行距

// =============================================================================
// 默认版面参数（按 Word 版式；可在 proposalclass(cfg: (...)) 覆盖）
// =============================================================================

#let default-proposal-cfg = (
  // A4；左右 3.17cm、上下 2.54cm（Word 页边距）
  margin: (x: 3.17cm, y: 2.54cm),
  // 封面
  logo-width: 12.8cm,
  cover-title-size: 字号.一号, // 26pt
  cover-field-size: 字号.小三, // 15pt
  cover-field-indent: 1.85em, // 对齐 Word 信息栏 x0≈116pt
  // 填表说明
  notice-title-size: 字号.小二, // 18pt
  notice-body-size: 字号.小四, // 12pt
  // Word 固定值 23 磅 → leading≈14.5pt（基线距≈23pt）
  notice-leading: 14.5pt,
  // 目录（样式对齐 pages/outline-page.typ / thesis 目录）
  outline-title: [目#h(1em)录],
  outline-title-size: 字号.四号,
  outline-depth: 2, // 开题默认收到二级；论文目录为 3
  // 与 thesis outline-page 相同的规范值
  outline-title-above: 24pt,
  outline-title-below: 18pt,
  outline-entry-size: (字号.四号, 字号.小四),
  outline-entry-font: auto, // auto → (黑体, 黑体)
  outline-entry-above: (6pt, 6pt),
  outline-entry-below: (0pt, 0pt),
  outline-indent: (0pt, 12pt),
  // prefix 后 h(gap)：编号内全角空格 1em + 0.3em，合计约 1.3em
  outline-gap: 1.3em,
  // 点线使用半角句点密排（repeat([.], gap: 0.12em)）；点线与页码置于
  // 兄弟 text，固定 Times New Roman、小四
  outline-fill: (repeat([.], gap: 0.12em),),
  body-size: 字号.小四, // 12pt
  // 与 layouts/mainmatter.typ 相同：leading/spacing 取 行距.正文（1.1em）
  body-leading: 行距.正文,
  body-spacing: 行距.正文,
  // 标题字体与字号（对齐学位论文）
  heading-font: none, // none → 运行时用 fonts.黑体
  heading-size: (字号.四号, 字号.小四, 字号.小四),
  heading-weight: ("bold", "regular", "regular"),
  // 段前段后（对齐 layouts/mainmatter.typ 规范值）
  // L1：段前 24pt、段后 18pt；L2：24pt / 6pt；L3：12pt / 6pt
  heading-above: (24pt, 24pt, 12pt),
  heading-below: (18pt, 6pt, 6pt),
  first-line-indent: (amount: 2em, all: true),
)

// =============================================================================
// 辅助
// =============================================================================

// =============================================================================
// 指导教师（info 必填）
//
// 在下列两种形式中填写且仅填写一种。未使用的键可省略，无需写 none：
//   supervisors-full : 整行字符串，如 "李四教授" / "李四教授 王五研究员"
//   supervisors-split: 分栏字典 (name: "李四", title: "教授")，name 必填且非空
// 两种同时填写或均未填写时，编译报错；split 缺非空 name 单独报错。
// 按已填写的形式展示。
// =============================================================================

#let _supervisor-full-filled(v) = {
  v != none and type(v) == str and v.trim() != ""
}

#let _supervisor-split-filled(v) = {
  if v == none or type(v) != dictionary {
    return false
  }
  let n = v.at("name", default: none)
  type(n) == str and n.trim() != ""
}

#let resolve-supervisor-display(full: none, split: none) = {
  let has-full = _supervisor-full-filled(full)
  let has-split = _supervisor-split-filled(split)

  if not has-split and split != none and type(split) == dictionary {
    panic(
      "info.supervisors-split 须包含非空 name（如 (name: \"李四\", title: \"教授\")）",
    )
  }

  if has-full and has-split {
    panic(
      "指导教师仅可填写一种形式：请仅保留 info.supervisors-full 或 info.supervisors-split 其一",
    )
  }
  if not has-full and not has-split {
    panic(
      "指导教师不可为空：请填写 info.supervisors-full 或 info.supervisors-split 其一",
    )
  }

  if has-full {
    return (mode: "full", line: full)
  }

  (
    mode: "split",
    name: split.name.trim(),
    title: {
      let t = split.at("title", default: "")
      if type(t) == str { t } else { str(t) }
    },
  )
}

#let format-date(d) = {
  if type(d) == datetime {
    let y = str(d.year())
    let m = if d.month() < 10 { "0" + str(d.month()) } else { str(d.month()) }
    let day = if d.day() < 10 { "0" + str(d.day()) } else { str(d.day()) }
    y + "年" + m + "月" + day + "日"
  } else {
    d
  }
}

// 开题报告标题层级编号：1. / 1.1. / 1.1.2（末级不加点）
#let proposal-numbering(..nums) = {
  let parts = nums.pos().map(str)
  if parts.len() == 0 {
    none
  } else if parts.len() == 1 {
    [#parts.at(0).]
  } else if parts.len() == 2 {
    [#parts.at(0).#parts.at(1).]
  } else {
    [#parts.join(".")]
  }
}

// 页脚：第X页，共Y页（从目录起编）
#let proposal-page-footer(fonts: (:)) = context {
  set text(font: fonts.宋体, size: 字号.五号)
  set align(center)
  [第#counter(page).display()页，共#counter(page).final().first()页]
}

// 封面信息栏标签（宋体小三加粗）
#let info-key(body, fonts: (:), cfg: (:)) = {
  set text(font: fonts.宋体, size: cfg.cover-field-size, weight: "bold")
  text(bottom-edge: "descender", body)
}

// 封面信息栏：整行横线（非仅文字下划线）。
// 已填内容按实际行数在每行下方画满宽横线；空值保留一行满宽横线。
#let info-value(body, fonts: (:), cfg: (:)) = {
  set text(font: fonts.宋体, size: cfg.cover-field-size, weight: "regular")
  set align(center)
  let v = if type(body) == str {
    body.split("\n").intersperse(linebreak()).sum(default: "")
  } else {
    body
  }
  if v == none or v == "" {
    box(width: 100%, height: 1.15em, stroke: (bottom: 0.5pt + black))
  } else {
    layout(avail => {
      let leading = 0.55em
      let content = {
        set par(leading: leading, justify: false)
        text(bottom-edge: "descender", v)
      }
      let size = cfg.cover-field-size
      // 15pt 时：字面高≈0.91em，行距≈1.49em；横线在字面底边再留 1.5pt
      let ink = size * 0.91
      let line-spacing = size * 1.49
      let m = measure(block(width: avail.width, content))
      let n = calc.max(1, calc.ceil(
        m.height.to-absolute() / line-spacing.to-absolute(),
      ))
      box(
        width: 100%,
        height: m.height,
        {
          for i in range(n) {
            place(
              top + left,
              dy: i * line-spacing + ink + 1.5pt,
              line(length: 100%, stroke: 0.5pt + black),
            )
          }
          align(center + top, block(width: 100%, content))
        },
      )
    })
  }
}

// =============================================================================
// 全局页面（doc）
// =============================================================================

#let proposal-doc(
  fonts: (:),
  cfg: (:),
  it,
) = {
  set page(
    paper: "a4",
    margin: cfg.margin,
    numbering: none,
    footer: none,
  )
  set text(
    font: fonts.宋体,
    size: cfg.body-size,
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )
  set par(
    leading: cfg.body-leading,
    spacing: cfg.at("body-spacing", default: cfg.body-leading),
    justify: true,
  )
  it
}

// =============================================================================
// 封面（版式对照 Word 空表：校徽 → 标题 → 信息栏 →「中国科学院大学制」沉底）
// =============================================================================

#let proposal-cover(
  doctype: "master",
  fonts: (:),
  info: (:),
  cfg: (:),
) = {
  // 本科生与研究生共用同一封面标题
  let cover-title = if doctype == "bachelor" {
    "研究生学位论文开题报告"
  } else {
    "研究生学位论文开题报告"
  }

  {
    set align(center)
    set par(leading: 1em, justify: false)

    // 校徽横版，与 Word 内嵌图一致（12.81×2.19cm）
    v(1.25cm)
    image("../assets/vi/ucas-logo-H.svg", width: cfg.logo-width)

    v(0.35cm)
    text(
      font: fonts.宋体,
      size: cfg.cover-title-size,
      weight: "bold",
      cover-title,
    )

    // 信息栏：对齐 Word 首行 y≈456pt
    v(6.9cm)
    set align(left)
    pad(
      left: cfg.cover-field-indent,
      right: cfg.cover-field-indent,
      block({
        set text(font: fonts.宋体, size: cfg.cover-field-size)
        set par(leading: 1em, justify: false)
        // 每行独立 grid，避免被最长标签「研究所（院系）」撑宽
        let full-row(label, value) = grid(
          columns: (auto, 1fr),
          column-gutter: 0.45em,
          align: top,
          info-key(label, fonts: fonts, cfg: cfg),
          info-value(value, fonts: fonts, cfg: cfg),
        )
        let pair-row(l1, v1, l2, v2) = grid(
          columns: (auto, 3.6em, auto, 1fr),
          column-gutter: 0.45em,
          align: top,
          info-key(l1, fonts: fonts, cfg: cfg),
          info-value(v1, fonts: fonts, cfg: cfg),
          info-key(l2, fonts: fonts, cfg: cfg),
          info-value(v2, fonts: fonts, cfg: cfg),
        )
        // Word 信息栏行距约 31pt（由行高自然形成）
        full-row("报告题目", info.title)
        pair-row("学生姓名", info.author, "学号", info.student-id)
        // 指导教师：在 supervisors-full / supervisors-split 中填写一种
        {
          let sup = resolve-supervisor-display(
            full: info.at("supervisors-full", default: none),
            split: info.at("supervisors-split", default: none),
          )
          if sup.mode == "split" {
            pair-row("指导教师", sup.name, "职称", sup.title)
          } else {
            full-row("指导教师", sup.line)
          }
        }
        full-row("学位类别", info.degree-category)
        full-row("学科专业", info.major)
        full-row("研究方向", info.research-direction)
        full-row("研究所（院系）", info.department)
        full-row("填表日期", format-date(info.submit-date))
      }),
    )

    // 剩余空间压到底部
    v(1fr)
    set align(center)
    text(
      font: fonts.宋体,
      size: cfg.cover-field-size,
      weight: "bold",
      "中国科学院大学制",
    )
    v(0.62cm)
  }

  pagebreak()
}

// =============================================================================
// 填表说明
// =============================================================================

#let proposal-notice(
  fonts: (:),
  cfg: (:),
  body: auto,
) = {
  {
    set align(center)
    set par(justify: false)
    v(1.35cm)
    text(
      font: fonts.宋体,
      size: cfg.notice-title-size,
      weight: "bold",
      tracking: 0.6em,
      "填表说明",
    )
  }

  v(0.82cm)

  {
    set text(font: fonts.宋体, size: cfg.notice-body-size)
    // Word：小四、固定值 23 磅
    set par(leading: cfg.notice-leading, justify: true, first-line-indent: 0em)
    set enum(numbering: "1.", indent: 0.9em, body-indent: 0.25em)

    if body == auto {
      enum(
        [本表内容须真实、完整、准确。],
        [
          “学位类别”名称：学术型学位填写哲学博士、教育学博士、理学博士、工学博士、农学博士、医学博士、管理学博士，哲学硕士、经济学硕士、法学硕士、教育学硕士、文学硕士、理学硕士、工学硕士、农学硕士、医学硕士、管理学硕士等；专业学位填写工程博士、工程硕士、工商管理硕士（MBA）、应用统计硕士、翻译硕士、应用心理硕士、农业推广硕士、工程管理硕士、药学硕士等。
        ],
        [
          “学科专业”名称：学术型学位填写“二级学科”全称；专业学位填写“培养领域”全称。
        ],
      )
    } else {
      body
    }
  }

  pagebreak()
}

// =============================================================================
// 目录（样式对齐 pages/outline-page.typ）
// 开题差异：标题文案、深度默认 2、无章眉罗马页码、页脚由 mainmatter
// 提供「第X页，共Y页」、编号为 1. / 1.1.（非「第1章」）。
// =============================================================================

#let proposal-outline-page(
  fonts: (:),
  cfg: (:),
  depth: auto,
) = {
  let outline-depth = if depth == auto { cfg.outline-depth } else { depth }
  let title = cfg.at("outline-title", default: [目#h(1em)录])
  let title-above = cfg.at("outline-title-above", default: 24pt)
  let title-below = cfg.at("outline-title-below", default: 18pt)
  let size = cfg.at("outline-entry-size", default: (字号.四号, 字号.小四))
  let entry-font = cfg.at("outline-entry-font", default: auto)
  if entry-font == auto {
    entry-font = (fonts.黑体, fonts.黑体)
  }
  let above = cfg.at("outline-entry-above", default: (6pt, 6pt))
  let below = cfg.at("outline-entry-below", default: (0pt, 0pt))
  // Typst outline(indent:) 的 level 为 0 基
  let indent = cfg.at("outline-indent", default: (0pt, 12pt))
  let gap = cfg.at("outline-gap", default: 1.3em)
  let fill = cfg.at("outline-fill", default: (repeat([.], gap: 0.12em),))

  // 标题
  v(title-above)
  {
    set align(center)
    set par(leading: 行距.单倍, spacing: 0pt)
    text(
      font: fonts.黑体,
      size: cfg.at("outline-title-size", default: 字号.四号),
      weight: "bold",
      title,
    )
  }
  v(title-below)

  // 序号与题名使用条目字体字号；点线与页码使用兄弟 text（Times 小四），
  // 与 pages/outline-page.typ 保持一致
  set outline(indent: level => indent
    .slice(0, calc.min(level + 1, indent.len()))
    .sum())
  show outline.entry: entry => {
    set par(leading: 行距.单倍, spacing: 0pt)
    let current-size = size.at(entry.level - 1, default: size.last())
    let current-above = above.at(entry.level - 1, default: above.last())
    let current-below = below.at(entry.level - 1, default: below.last())
    let row-font = entry-font.at(entry.level - 1, default: entry-font.last())
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
          text(
            font: row-font,
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

  outline(title: none, depth: outline-depth)

  pagebreak()
}

// =============================================================================
// 正文布局
// 样式（字号/行距/段前段后/标题字重）对齐 layouts/mainmatter.typ；
// 差异仅在：标题编号 1. / 1.1. / 1.1.2（非「第1章」）、一级标题顶左不居中、
// 无章眉、页脚为「第X页，共Y页」、不自动章换页。
// =============================================================================

#let proposal-mainmatter(
  fonts: (:),
  info: (:),
  cfg: (:),
  it,
) = {
  set page(
    paper: "a4",
    margin: cfg.margin,
    numbering: none,
    footer: proposal-page-footer(fonts: fonts),
  )
  counter(page).update(1)

  // 与学位论文一致：修剪行盒边缘，使 leading 对应真实基线距
  set text(
    font: fonts.宋体,
    size: cfg.body-size,
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )
  set par(
    leading: cfg.body-leading,
    spacing: cfg.at("body-spacing", default: cfg.body-leading),
    justify: true,
    first-line-indent: cfg.first-line-indent,
  )
  set heading(numbering: proposal-numbering)

  let heading-font = if cfg.at("heading-font", default: none) != none {
    cfg.heading-font
  } else {
    fonts.黑体
  }

  // 标题：字体字号 / 段前段后 均取学位论文同一套规范值
  show heading: it => {
    let lvl = calc.min(it.level, cfg.heading-size.len())
    // 标题单倍行距（同 mainmatter：行距.单倍）
    set par(
      leading: 行距.单倍,
      spacing: 行距.单倍,
      first-line-indent: 0em,
      justify: false,
    )
    set text(
      font: heading-font,
      size: cfg.heading-size.at(lvl - 1),
      weight: cfg.heading-weight.at(lvl - 1),
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )
    // 段前用 block(above) 与相邻块 max 折叠（同 mainmatter L2+）；
    // 段后额外补一个正文 leading，避免标题基线与首行粘连。
    set block(
      above: cfg.heading-above.at(lvl - 1),
      below: cfg.heading-below.at(lvl - 1) + 13.2pt,
    )
    it
  }

  it
}
