// 中国科学院大学学位论文开题报告（本科 / 研究生）
//
// 编译：
//   typst compile template/proposal.typ --root . --font-path fonts
//
// 用法与 template/thesis.typ 同构：重要参数集中在 proposalclass，
// 正文用 = / == / === 写层级标题（编号 1. / 1.1. / 1.1.2），段落自动首行缩进。

//#import "@preview/modern-ucas-thesis:0.3.0": proposalclass
#import "../lib.typ": proposalclass

#let (
  doc,
  cover,
  notice,
  outline-page,
  mainmatter,
  bilingual-bibliography,
  // 正文工具（按需解构）
  bifigure,
  bitable,
  continued-table,
  auto-table,
  aligned-equation,
) = proposalclass(
  doctype: "master", // "bachelor" | "master"；本科生版式暂与研究生一致
  fontset: "mac", // "windows" | "mac" | "fandol" | "adobe"
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")), // 可覆盖单项字体
  info: (
    // 题目：可用 \n 手动分行，例如 "上半段\\n下半段"
    title: "基于 Typst 的中国科学院大学学位论文开题报告排版方法研究",
    author: "张三",
    student-id: "1234567890",
    // 指导教师：在下列两种形式中填写且仅填写一种。
    // 未使用的键可省略；同时填写或均未填写时，编译报错。
    // 整行：
    // supervisors-full: "李四教授",
    // 分栏（与 supervisors-full 互斥，只需要填一个）：
    supervisors-split: (name: "李四", title: "教授"),
    degree-category: "工学硕士",
    major: "计算机科学与技术",
    research-direction: "智能信息处理",
    department: "中国科学院××研究所",
    submit-date: datetime.today(),
  ),
  // 文献库
  bibliography: bibliography.with("ref.bib"),
  // 版面微调（可选；键名见 pages/proposal.typ 的 default-proposal-cfg）
  // cfg: (outline-depth: 2),
)

// 文稿设置
#show: doc

// 封面
#cover()

// 填表说明（不需要此页时注释掉下行即可）
#notice()

// 正文
#show: mainmatter

// 目录（自动收集下列一级/二级标题）
#outline-page()

= 选题的背景及意义

在此撰写选题背景、理论意义与应用价值。可插入图表、公式与引用，例如森林群落分类研究#[@jiang1998]。

== 研究背景

说明领域现状、工程或科学需求，以及本课题的出发点。

== 理论意义

说明在理论或方法上的贡献与学术价值。

== 应用价值

说明成果转化、应用场景与社会效益。

= 国内外本学科领域的发展现状与趋势

在此综述国内外研究现状、典型工作与发展趋势，并指出本文切入点。可合并多篇文献#[@jiang1998@cstam1990]。

== 国外研究现状

按时间或技术路线梳理国外代表性工作。

== 国内研究现状

梳理国内相关进展、已有成果与不足。


== 研究述评与发展趋势

总结共性问题、尚未解决的难点，以及本课题的切入点与趋势判断。

= 课题主要研究内容、预期目标

在此分条列出主要研究内容与可考核的预期目标。

== 研究目标

明确本课题要达到的总体目标与可考核指标。

== 研究内容

+ 研究内容一……
+ 研究内容二……
+ 研究内容三……

== 拟解决的关键问题

列出 1–2 个拟突破的关键科学或技术问题。

== 预期目标与成果

说明预期成果形式（论文、系统、数据集等）与验收方式。

= 拟采用的研究方法、技术路线、实验方案及其可行性分析

在此说明研究方法、技术路线、实验/仿真方案，并论证可行性。

== 研究方法

说明所采用的理论、算法或实验方法。

== 技术路线

说明总体技术路线与各研究内容之间的关系（可配技术路线图）。

== 实验方案

说明实验/仿真设置、数据来源、评价指标与对比基线。


== 可行性分析

从理论、技术、数据与条件等方面论证方案可行。

= 已有研究基础与所需的研究条件

在此说明前期工作积累、软硬件条件、数据与协作单位等。

== 已有研究基础

说明预研结果、已发表工作或已掌握的关键技术。

== 所需研究条件

说明所需仪器设备、软件平台、数据与协作单位等保障条件。

= 研究工作计划与进度安排

== 研究工作计划

按阶段说明主要任务与阶段成果。

== 进度安排

#{
  let plan = (
    ("2026.09 – 2026.12", "文献调研，开题，确定技术路线"),
    ("2027.01 – 2027.06", "核心方法设计与原型实现"),
    ("2027.07 – 2027.12", "实验验证与系统优化"),
    ("2028.01 – 2028.03", "论文撰写与预答辩"),
    ("2028.04 – 2028.06", "论文送审、答辩与归档"),
  )
  table(
    columns: (9em, 1fr),
    align: (center + horizon, left + horizon),
    stroke: 0.5pt,
    inset: 8pt,
    [时间], [工作内容],
    ..plan.map(row => (row.at(0), row.at(1))).flatten(),
  )
}

// 参考文献：复用 template/ref.bib；不要在此再写「= 参考文献」小节
#bilingual-bibliography(full: true)
