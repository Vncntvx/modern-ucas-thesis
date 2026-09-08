#import "../utils/datetime-display.typ": datetime-display, datetime-en-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/supervisor.typ": (
  normalize-supervisors, supervisor-en-line, supervisor-line,
)

// 硕士研究生封面
#let master-cover(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  stroke-width: 0.5pt, // 控制元素边框（如框架、分隔线等）的线宽度。
  min-title-lines: 2, // 控制标题行数的最小值。
  min-supervisor-lines: 2, // 控制指导教师区域的最小行数。
  min-reviewer-lines: 5, // 控制评审人区域的最小行数。
  info-inset: (x: 0pt, bottom: 0pt), // 信息区域内边距；2 倍行距由 row-gutter 控制，bottom 清零避免干扰
  info-key-width: 70pt, // 控制信息标签（如“论文题目”、“作者姓名”）的宽度。
  info-column-gutter: 6pt, // 控制信息列之间的间距。
  info-row-gutter: 1em, // 2 倍行距：相邻行 baseline 间距 = 行高(1em) + gutter(1em) = 2em
  meta-block-inset: (left: -15pt), // 控制元数据块的内边距。
  meta-info-inset: (x: 0pt, bottom: 2pt), // 控制元信息区域的内边距。
  meta-info-key-width: 35pt, // 控制元信息标签的宽度（如“学位”、“提交日期”）。
  meta-info-column-gutter: 10pt, // 控制元信息列之间的间距。
  meta-info-row-gutter: 1pt, // 控制元信息行之间的间距。
  defence-info-inset: (x: 0pt, bottom: 0pt), // 控制答辩信息区域的内边距。
  defence-info-key-width: 110pt, // 控制答辩信息标签的宽度。
  defence-info-column-gutter: 2pt, // 控制答辩信息列之间的间距。
  defence-info-row-gutter: 12pt, // 控制答辩信息区域行与行之间的间距。
  anonymous-info-keys: (
    // 控制需要匿名化处理的字段。
    "student-id",
    "author",
    "author-en",
    "supervisors",
    "supervisors-en",
    "chairman",
    "reviewer",
    "department",
  ),
  datetime-display: datetime-display, // 用于格式化日期显示。
  datetime-en-display: datetime-en-display, // 用于格式化英文日期显示。
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: "基于 Typst 的中国科学院大学学位论文",
      title-en: "Typst Thesis Template of UCAS",
      supervisors: (
        (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
        (name: "王五", title: "研究员", affiliation: "中国科学院××研究所"),
      ),
      supervisors-en: (
        (name: "Si Li", title: "Professor", affiliation: "×× Institute, CAS"),
        (name: "Wu Wang", title: "Professor", affiliation: "×× Institute, CAS"),
      ),
      reviewer: (),
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      department: "XX 研究所",
      major: "某专业",
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
  // 2.1 导师信息校验并归一化为字典列表 (name:, title:, affiliation:)。
  info.supervisors = normalize-supervisors(info.supervisors)
  info.supervisors-en = normalize-supervisors(info.supervisors-en)
  // 2.2 根据 min-title-lines 和 min-reviewer-lines 填充标题和评阅人
  info.title = (
    info.title + range(min-title-lines - info.title.len()).map(it => "　")
  )
  info.reviewer = (
    info.reviewer
      + range(min-reviewer-lines - info.reviewer.len()).map(it => "　")
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
  // 2.3 处理日期
  assert(
    type(info.submit-date) == datetime,
    message: "submit-date must be datetime.",
  )
  if type(info.defend-date) == datetime {
    info.defend-date = datetime-display(info.defend-date)
  }
  if type(info.confer-date) == datetime {
    info.confer-date = datetime-display(info.confer-date)
  }
  if type(info.bottom-date) == datetime {
    info.bottom-date = datetime-display(info.bottom-date)
  }
  // 2.4 处理 degree
  if (info.degree == auto) {
    if (doctype == "doctor") {
      info.degree = "工程博士"
    } else {
      info.degree = "工程硕士"
    }
  }

  // 3.  内置辅助函数
  let info-key(body, info-inset: info-inset, is-meta: false) = {
    set text(
      font: if is-meta {
        fonts.宋体
      } else {
        fonts.宋体
      },
      size: if is-meta {
        字号.小五
      } else {
        字号.四号
      },
      weight: if is-meta {
        "regular"
      } else {
        "bold"
      },
    )

    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      justify-text(with-tail: is-meta, body),
    )
  }

  let info-value(
    key,
    body,
    info-inset: info-inset,
    is-meta: false,
    no-stroke: false,
  ) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke {
        none
      } else {
        (bottom: stroke-width + black)
      },
      text(
        font: if is-meta {
          fonts.宋体
        } else {
          fonts.宋体
        },
        weight: if is-meta {
          "regular"
        } else {
          "bold"
        },
        size: if is-meta {
          字号.小五
        } else {
          字号.四号
        },
        bottom-edge: "descender",
        if (anonymous and (key in anonymous-info-keys)) {
          if is-meta {
            "█████"
          } else {
            "██████████"
          }
        } else {
          body
        },
      ),
    )
  }

  let anonymous-text(key, body) = {
    if (anonymous and (key in anonymous-info-keys)) {
      "██████████"
    } else {
      body
    }
  }

  let meta-info-key = info-key.with(info-inset: meta-info-inset, is-meta: true)
  let meta-info-value = info-value.with(
    info-inset: meta-info-inset,
    is-meta: true,
  )
  let defence-info-key = info-key.with(info-inset: defence-info-inset)
  let defence-info-value = info-value.with(info-inset: defence-info-inset)

  // 4.  正式渲染
  pagebreak(weak: true)

  // 密级（规范一·（一）·1）：公开论文不标注；涉密/延迟公开论文标注密级，
  // 有保密期限的一并标注（如"秘密★10年"）。置于封面右上角，五号字。
  // secret-level/secret-year 经 info 传入（见 lib.typ 默认值）。
  let secret-level = info.at("secret-level", default: "公开")
  let secret-year = info.at("secret-year", default: none)
  if secret-level not in ("公开", "", none) {
    align(right, text(
      font: fonts.宋体,
      size: 字号.五号,
      weight: "bold",
      [密级：#secret-level#if secret-year != none [★#secret-year]],
    ))
  }

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
    if doctype == "doctor" {
      "博士学位论文"
    } else {
      "硕士学位论文"
    },
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
    // width: 294pt, 限制宽度
    grid(
      columns: (info-key-width, 1fr),
      column-gutter: info-column-gutter,
      row-gutter: info-row-gutter,
      info-key("作者姓名："),
      info-value("author", info.author),
      info-key("指导教师："),
      // 每位导师渲染为"姓名 职称 工作单位"单行（UCAS 规范：三项填于同一栏），
      // 多导师依次列出，第一导师在前。空字段自动跳过，空字典占位行渲染为空下划线栏。
      ..info
        .supervisors
        .map(s => info-value("supervisors", supervisor-line(s)))
        .intersperse(info-key("　")),
      info-key("学位类别："),
      info-value("category", info.category),
      ..(
        if degree == "professional" {
          (
            {
              set text(font: fonts.宋体, size: 字号.四号, weight: "bold")
              move(dy: 0.3em, scale(x: 55%, box(
                width: 10em,
                "专业学位类别（领域）",
              )))
            },
            info-value("major", info.degree + "（" + info.major + "）"),
          )
        } else {
          (
            info-key("学科专业："),
            info-value("major", info.major),
          )
        }
      ),
      info-key("培养单位："),
      info-value("department", info.department),
    ),
  )

  v(50pt)

  text(font: fonts.宋体, size: 字号.四号, weight: "bold", datetime-display(
    info.submit-date,
  ))

  // 第二页英文封面页（封面段单面：不插空白页，连续分页）
  pagebreak(weak: true)

  set text(font: fonts.楷体, size: 字号.四号)
  // 英文正文取正文行距（规范无定量；旧 1.3em 为额外间隙语义误用，约 2.3 倍行距）。
  set par(leading: 行距.正文, spacing: 行距.正文)

  v(80pt)

  // 英文题目单倍行距：用 block 限定 set par 作用域，覆盖页面级正文行距。
  // 题目下方英文正文段落仍用页面级行距（在该 block 之外）。
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
    A dissertation submitted to \
    #(
      if not anonymous {
        "University of Chinese Academy of Sciences"
      }
    ) \
    in partial fulfillment of the requirement \ for the degree of \
  ]

  if doctype == "doctor" {
    strong[Doctor of #info.category-en]
  } else {
    strong[Master of #info.category-en]
  }
  strong[\ in ]
  strong[#info.major-en]

  strong[
    \ By \ #text(anonymous-text("author-en", info.author-en)) \
  ]
  // 英文导师：每位渲染为"title name affiliation"单行（英文职称在前，如 "Professor Si Li"），
  // 多导师依次列出。单导师用 "Supervisor: "，多导师用 "Supervisors: " + 换行缩进。
  // 无导师时整行省略，避免悬空冒号。
  let supers = info.supervisors-en.map(s => anonymous-text(
    "supervisors-en",
    supervisor-en-line(s),
  ))
  if supers.len() >= 1 {
    text(
      weight: "bold",
      if supers.len() == 1 {
        "Supervisor: " + supers.at(0)
      } else {
        (
          "Supervisors: "
            + supers
              .intersperse(
                "\n                               ",
              )
              .sum()
        )
      },
    )
  }

  v(90pt)

  if not anonymous {
    strong[#info.department-en, Chinese Academy of Sciences]
  } else { v(26pt) }

  v(28pt)

  strong[#datetime-en-display(info.submit-date)]
}
