#import "../utils/datetime-display.typ": (
  datetime-display-compact, datetime-en-display-long,
)
#import "../utils/justify-text.typ": justify-text
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/supervisor.typ": (
  normalize-supervisors, supervisor-en-name, supervisor-line,
)

// 本科生封面（中文封面 + 英文封面）
//
// 依据《中国科学院大学本科生毕业论文（设计）撰写规范指导意见》三·（二）封面
// 及样张1/样张2：
// - 论文题目 黑体小三号加粗居中，单倍行距；
// - 作者姓名/指导教师（姓名、专业技术职务、工作单位）/学位类别/专业/学院（系）
//   宋体四号加粗，2 倍行距；
// - 时间用阿拉伯数字，Times New Roman 体四号加粗居中。
// 英文封面同表：题目 Times New Roman 小三号加粗居中、单倍行距，其余 Times New
// Roman 四号加粗居中、2 倍行距；学位类别按学科门类（Bachelor of Science 等）。
// 版式沿用研究生封面（两规范封面要求一致），仅替换标题、字段与学位表述。
#let bachelor-cover(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  stroke-width: 0.5pt, // 控制元素边框（如框架、分隔线等）的线宽度。
  min-title-lines: 2, // 控制标题行数的最小值。
  min-supervisor-lines: 2, // 控制指导教师区域的最小行数。
  info-inset: (x: 0pt, bottom: 0pt), // 信息区域内边距；2 倍行距由 row-gutter 控制，bottom 清零避免干扰
  info-key-width: 74pt, // 控制信息标签（如“作者姓名”、“指导教师”）的宽度。
  info-column-gutter: 6pt, // 控制信息列之间的间距。
  info-row-gutter: 1.60em, // 2 倍行距（Word 口径）：相邻行基线距 = 行盒 + gutter ≈ 2.5em ≈ 35pt@四号（官方样稿实测 34.95pt）
  anonymous-info-keys: (
    // 控制需要匿名化处理的字段。
    "author",
    "author-en",
    "supervisors",
    "supervisors-en",
    "department",
  ),
  datetime-display: datetime-display-compact, // 中文封面日期格式（"20XX年X月"，对齐本科样张）。
  datetime-en-display: datetime-en-display-long, // 英文封面日期格式（"June 20XX"）。
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: "基于 Typst 的中国科学院大学本科毕业论文",
      title-en: "Bachelor's Thesis of UCAS Based on Typst",
      supervisors: (
        (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
        (name: "王五", title: "研究员", affiliation: "中国科学院××研究所"),
      ),
      supervisors-en: (
        (
          name: "LI Si",
          title: "Professor",
          affiliation: "Institute of XXX, Chinese Academy of Sciences",
        ),
        (
          name: "WU Wang",
          title: "Professor",
          affiliation: "Institute of XXX, Chinese Academy of Sciences",
        ),
      ),
      author: "张三",
      author-en: "ZHANG San",
      department: "中国科学院大学××学院",
      department-en: "School of XXX, University of Chinese Academy of Sciences",
      major: "某专业",
      major-en: "XX Major",
      // 学位类别：学科门类 + 学位级别（如“理学学士”）；英文按学科门类填写，
      // 如理学类 Bachelor of Science、工学类 Bachelor of Engineering（样张2）。
      category: "理学学士",
      category-en: "Science",
      submit-date: datetime.today(),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 2.2 导师信息校验并归一化为字典列表 (name:, title:, affiliation:)。
  info.supervisors = normalize-supervisors(info.supervisors)
  info.supervisors-en = normalize-supervisors(info.supervisors-en)
  // 2.3 根据 min-title-lines 填充标题
  info.title = (
    info.title + range(min-title-lines - info.title.len()).map(it => "　")
  )
  // 填充导师列表至 min-supervisor-lines 行，空行用空字典占位（渲染为空下划线栏）
  info.supervisors = (
    info.supervisors
      + range(min-supervisor-lines - info.supervisors.len()).map(it => (
        name: "",
        title: "",
        affiliation: "",
      ))
  )
  // 2.4 处理日期
  assert(
    type(info.submit-date) == datetime,
    message: "submit-date must be datetime.",
  )

  // 3.  内置辅助函数
  // 信息标签：宋体四号加粗，用 justify-text 使标签两端对齐（保持竖排标点位置一致）。
  // 文字边缘与 info-value 同口径（cap-height→descender），使各信息行行盒一致，
  // 行距才严格等于 info-row-gutter + 行盒（否则标签行会比取值行矮约 1pt）。
  let info-key(body, info-inset: info-inset) = {
    set text(
      font: fonts.宋体,
      size: 字号.四号,
      weight: "bold",
      top-edge: "cap-height",
      bottom-edge: "descender",
    )

    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      justify-text(body),
    )
  }

  let anonymous-text(key, body) = {
    if (anonymous and (key in anonymous-info-keys)) {
      "██████████"
    } else {
      body
    }
  }

  // 信息值：宋体四号加粗居中，下划线由 rect 底边提供
  let info-value(key, body, info-inset: info-inset) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stroke-width + black),
      text(
        font: fonts.宋体,
        weight: "bold",
        size: 字号.四号,
        bottom-edge: "descender",
        anonymous-text(key, body),
      ),
    )
  }

  // 4.  中文封面（封面段单面：不强制奇偶页，连续分页）
  pagebreak(weak: true)

  v(80pt)

  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if (anonymous) {
    v(93.5pt)
  } else {
    // 封面图标
    image("../assets/vi/ucas-logo-H-standard.svg", height: 2.2cm)
  }

  v(26pt)

  text(
    size: 字号.一号,
    font: fonts.黑体,
    spacing: 200%,
    weight: "bold",
    "学士学位论文",
  )

  v(28pt)

  // 中文题目单倍行距（多行标题才显现差异；text.spacing 是字距参数，不管行距）
  [
    #set par(leading: 行距.单倍, spacing: 0pt)
    #text(
      size: 字号.小三,
      font: fonts.黑体,
      spacing: 100%,
      weight: "bold",
      underline(
        offset: .4em,
        stroke: .05em,
        evade: false,
      )[#(info.title.sum())],
    )
  ]

  v(56pt)

  block(
    grid(
      columns: (info-key-width, 1fr),
      column-gutter: info-column-gutter,
      row-gutter: info-row-gutter,
      info-key("作者姓名："),
      info-value("author", info.author),
      info-key("指导教师："),
      // 每位导师渲染为"姓名 职称 工作单位"单行（本科规范：三项填于同一栏），
      // 多导师依次列出，第一导师在前。空字段自动跳过，空字典占位行渲染为空下划线栏。
      ..info
        .supervisors
        .map(s => info-value("supervisors", supervisor-line(s)))
        .intersperse(info-key("　")),
      info-key("学位类别："),
      info-value("category", info.category),
      info-key("专业："),
      info-value("major", info.major),
      info-key("学院（系）："),
      info-value("department", info.department),
    ),
  )

  v(50pt)

  text(font: fonts.宋体, size: 字号.四号, weight: "bold", datetime-display(
    info.submit-date,
  ))

  // 5.  英文封面页（封面段单面：不插空白页，连续分页）
  pagebreak(weak: true)

  // 英文信息行取规范"2 倍行距"（Word 口径 = 2 × 单倍行高）：Times 四号的单倍行高
  // ≈1.15em（ascent+descent+lineGap），目标基线距 2.3em ≈ 32.2pt；行盒按
  // cap-height→descender 修剪后实测 ≈0.878em，故 leading/spacing 取 1.42em
  //（实测基线距 32.2pt，与本科样张 2 的 32.8pt 一致）。
  set text(
    font: fonts.楷体,
    size: 字号.四号,
    top-edge: "cap-height",
    bottom-edge: "descender",
  )
  set par(leading: 1.42em, spacing: 1.42em)

  v(80pt)

  // 英文题目单倍行距：用 block 限定 set par 作用域，覆盖页面级正文行距。
  block[
    #set par(leading: 行距.单倍, spacing: 0pt)
    #text(
      font: "Times New Roman",
      size: 字号.小三,
      weight: "bold",
      underline(offset: .4em, stroke: .05em, evade: false)[#(
        info.title-en.intersperse("\n").sum()
      )],
    )
  ]

  v(85pt)

  strong[
    A thesis submitted to \
    #(
      if not anonymous {
        "University of Chinese Academy of Sciences"
      }
    ) \
    in partial fulfillment of the requirement \ for the degree of \
  ]

  // 学位类别按学科门类（如 Bachelor of Science / Bachelor of Engineering）
  strong[Bachelor of #info.category-en]
  strong[\ in ]
  strong[#info.major-en]

  strong[
    \ By \ #text(anonymous-text("author-en", info.author-en)) \
  ]
  // 英文导师：只列职称与姓名（本科样张 2 与 LaTeX 参考 Supervisor: Professor LI Si），
  // 工作单位已在中文封面完整给出。单导师一行；多导师用两列 grid 对齐序号与姓名，
  // 后续导师与第一位的姓名左端对齐（不用空格撑位）。无导师时整行省略，避免悬空冒号。
  let supers = info.supervisors-en.map(s => anonymous-text(
    "supervisors-en",
    supervisor-en-name(s),
  ))
  if supers.len() == 1 {
    text(weight: "bold", "Supervisor: " + supers.at(0))
  } else if supers.len() > 1 {
    text(
      weight: "bold",
      grid(
        columns: (auto, auto),
        column-gutter: 0.4em,
        align: (left, left),
        "Supervisors:", supers.join("\n"),
      ),
    )
  }

  v(90pt)

  if not anonymous {
    strong[#info.department-en]
  } else { v(26pt) }

  v(28pt)

  strong[#datetime-en-display(info.submit-date)]
}
