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

// 填表说明
#notice()

// 提纲 + 正文（页码从提纲起编）
#show: mainmatter

// 目录（自动收集下列一级/二级标题）
#outline-page()

= 选题的背景及意义

在此撰写选题背景、理论意义与应用价值。可插入图表、公式与引用，例如森林群落分类研究#[@jiang1998]。

#lorem(40)

== 理论意义

二级标题编号形如 1.1.。正文段落默认首行缩进 2em。

== 应用价值

三级标题形如 1.1.2，可在更深层继续使用 `===`。

= 国内外本学科领域的发展现状与趋势

在此综述国内外研究现状、典型工作与发展趋势，并指出本文切入点。可合并多篇文献#[@jiang1998@cstam1990]。

#lorem(50)

= 课题主要研究内容、预期目标

在此分条列出主要研究内容与可考核的预期目标。

+ 研究内容一……
+ 研究内容二……
+ 预期目标……

= 拟采用的研究方法、技术路线、实验方案及其可行性分析

在此说明研究方法、技术路线、实验/仿真方案，并论证可行性。

#lorem(45)

= 已有研究基础与所需的研究条件

在此说明前期工作积累、软硬件条件、数据与协作单位等。

#lorem(30)

= 研究工作计划与进度安排

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
