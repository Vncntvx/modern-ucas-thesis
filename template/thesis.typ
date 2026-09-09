//#import "@preview/modern-ucas-thesis:0.3.0": documentclass
#import "../lib.typ": documentclass
#import "../pages/degree-table.typ": degree-table
// 你首先应该安装 fonts下的所有字体，或在编译的时候指定字体路径：
// typst watch template/thesis.typ --root . --font-path ./fonts
// 如果是 Web App 上编辑，你应该手动上传所有字体文件，否则部分字体不能正常使用，导致显示错误。
#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  appendix,
  // 页面函数
  fonts-display-page,
  cover,
  decl-page,
  abstract,
  abstract-en,
  bilingual-bibliography,
  outline-page,
  list-of-figures-and-tables,
  notation,
  acknowledgement,
  backmatter,
  bifigure,
  bitable,
  continued-table,
  auto-table,
  aligned-equation,
  // 定理类数学环境
  axiom,
  theorem,
  lemma,
  corollary,
  assertion,
  proposition,
  conjecture,
  definition,
  example,
  remark,
  proof,
) = documentclass(
  doctype: "doctor", // "bachelor" | "master" | "doctor", 文档类型，默认为博士生 doctor
  degree: "academic", // "academic" | "professional", 学位类型，默认为学术型 academic
  anonymous: false, // 盲审模式
  twoside: true, // 双面模式，会加入空白页，便于打印
  fontset: "mac", // 选择预定义的字体组："windows" | "mac" | "fandol" | "adobe"
  // fonts参数可用于覆盖或补充fontset中的字体设置
  // 例如：仅想更改某一种字体时，可以这样设置
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  // 或者需要自定义特定字体以解决警告和兼容性问题时
  // fonts: (黑体: (name: "Times New Roman", covers: "latin-in-cjk"), "SimHei")),
  info: (
    title: ("基于 Typst 的", "中国科学院大学学位论文"),
    title-en: "Thesis/Dissertation of UCAS Based on Typst",
    // 导师信息：结构化字典列表 (name:, title:, affiliation:)，多导师第一导师在前。
    // 完整填写"姓名、专业技术职务、工作单位"三项（《指导意见》一·（一）·4）。
    supervisors: (
      (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
      (name: "王五", title: "研究员", affiliation: "中国科学院××研究所"),
    ),
    supervisors-en: (
      (
        name: "Si Li",
        title: "Professor",
        affiliation: "Institute of XXX, Chinese Academy of Sciences",
      ),
      (
        name: "Wu Wang",
        title: "Professor",
        affiliation: "Institute of XXX, Chinese Academy of Sciences",
      ),
    ),
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Zhang San",
    department: "中国科学院××研究所",
    department-en: "Institute of XXX",
    major: "管理科学与工程",
    major-en: "Management Science and Engineering",
    category: "管理学博士",
    category-en: "Management Science",
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)

// 文稿设置
#show: doc

// 字体展示测试页
// #fonts-display-page()

// 封面页
#cover()

// 声明页
#decl-page()


// 前言
#show: preface

// 中文摘要
#abstract(keywords: ("中国科学院大学", "学位论文", "模板"))[
  中文摘要、英文摘要、目录、论文正文、参考文献、附录、致谢、攻读学位期间发表的学术论文与其他相关学术成果等均须由另页右页（奇数页）开始。
]

// 英文摘要
#abstract-en(keywords: (
  "University of Chinese Academy of Sciences",
  "Thesis",
  "Typst Template",
))[
  Chinese abstracts, English abstracts, table of contents, the main contents, references, appendix, acknowledgments,
  author's resume and academic papers published during the degree study and other relevant academic achievements must
  start with another right page (odd-numbered page).
]

// 目录
#outline-page()

// 图表目录
#list-of-figures-and-tables()

// 符号列表
#notation()[

  字符

  // @typstyle off
  #table(
    columns: (1fr, auto, auto),
    align: (left, left, left),
    stroke: none,
    // 表格内容与左边距的距离为 0，使其与正文完全左对齐
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*][*Unit*],
    [$R$], [the gas constant], [$m^2 dot s^(-2) dot K^(-1)$],
    [$C_v$], [specific heat capacity at constant volume], [$m^2 dot s^(-2) dot K^(-1)$],
    [$C_p$], [specific heat capacity at constant pressure], [$m^2 dot s^(-2) dot K^(-1)$],
    [$E$], [specific total energy], [$m^2 dot s^(-2)$],
    [$e$], [specific internal energy], [$m^2 dot s^(-2)$],
    [$h_T$], [specific total enthalpy], [$m^2 dot s^(-2)$],
    [$h$], [specific enthalpy], [$m^2 dot s^(-2)$],
    [$k$], [thermal conductivity], [$"kg" dot m dot s^(-3) dot K^(-1)$],
    [$S_(i j)$], [deviatoric stress tensor], [$"kg" dot m^(-1) dot s^(-2)$],
    [$tau_(i j)$], [viscous stress tensor], [$"kg" dot m^(-1) dot s^(-2)$],
    [$delta_(i j)$], [Kronecker delta], [1],
    [$I_(i j)$], [identity tensor], [1],
  )

  算子

  #table(
    columns: (1fr, auto),
    align: (left, left),
    stroke: none,
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*],
    [$Delta$], [difference],
    [$nabla$], [gradient operator],
    [$delta^(plus.minus)$], [upwind-biased interpolation scheme],
  )

  缩写

  #table(
    columns: (1fr, auto),
    align: (left, left),
    stroke: none,
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*],
    [CFD], [Computational Fluid Dynamics],
    [CFL], [Courant-Friedrichs-Lewy],
    [EOS], [Equation of State],
    [JWL], [Jones-Wilkins-Lee],
    [WENO], [Weighted Essentially Non-Oscillatory],
    [ZND], [Zeldovich-von Neumann-Döring],
  )
]

// 正文
#show: mainmatter

= 绪论<chap:introduction>

== 背景

2022年3月7日审议修订的《中国科学院大学研究生学位论文撰写规范和指导意见》（以下简称《指导意见》，正文为2021年修订版）从2023年冬季批次开始实施。这一份基于 Typst 的社区模板（非学校官方出品），用于辅助按《指导意见》撰写硕士、博士学位论文，并兼顾本科生毕业论文（设计）的常用结构。使用时，您只需在相应章节填写研究内容，并按第2章说明配置论文元信息即可；具体格式以所在培养单位的最新要求为准，提交前请自行核对。

第2章介绍模板的安装、编译与项目结构；第3章摘录《指导意见》中与内容和格式相关的部分要求，便于对照自查。请在正式撰写前仔细阅读。

== Typst 简介<sec:typst-intro>

#link("https://typst.app/")[Typst] 是一种开源、跨平台的基于标记语言的排版系统。按官方描述，它以排版自动化、输出质量与编译速度为主要设计目标，适用于信函、幻灯片、学位论文等多种文档类型。其标记语法接近 Markdown，版式则通过 `set` / `show` 规则与模板统一控制，使内容与格式相分离。编译器以 Rust 实现，采用增量编译机制：源码修改后仅重新计算受影响的部分，配合 `watch` 命令或编辑器扩展，撰写过程中即可实时预览分页、页眉与交叉引用的变化。

Typst 将学位论文写作中的高频能力内建于语言核心与标准库，多数常用功能无需引入第三方包即可直接使用。结合官方文档，其主要能力可归纳如下：

(a) 数学公式：公式排版内建于语言核心，可直接书写分式、矩阵、上下标与对齐等结构，能够满足研究型论文的公式表达需求；

(b) 图表与表格：支持插图与绘图元素；表格既可手工书写，也可由 CSV、JSON 等结构化数据载入生成，便于与实验数据联动；

(c) 参考文献与引用：可自动格式化文中引用与文末文献表，兼容 BibTeX 文献库，并可与 Zotero、Mendeley 等文献管理工具配合使用；

(d) 代码排版：内置语法高亮，支持行号与配色主题等配置，便于插入算法或示例代码；

(e) 样式与脚本：通过 `set` / `show` 规则分离内容与格式，并提供条件、循环、函数与方法等脚本能力，支持定义可复用的版式；

(f) 文档自省与数据载入：可在排版过程中查询元素的位置与计数，页眉、目录与交叉引用等功能即基于该机制实现；同时支持从 JSON、YAML、CSV 等文件读取数据并生成内容。

== Typst 与 LaTeX 的主要差异<sec:typst-vs-latex>

Typst 与 LaTeX 的总体目标一致：以自动化排版达成学位论文级别的版面质量，但二者的实现路径不同。LaTeX 建立在 TeX 排版引擎与宏展开机制之上，生态历经数十年积累；Typst 则重新设计了标记语言与编译器，保留学术排版的核心目标。对于有 LaTeX 使用经验的作者，二者的差异主要体现在语法与学习成本、编译与预览、生态与能力分布、可编程性、版面模型与诊断五个方面。

语法与学习成本方面，LaTeX 的命令以反斜杠与花括号为主，宏展开语义灵活但不易预测，初学者常在宏包缺失、选项冲突等问题上耗费时间；Typst 的标记语法接近 Markdown，标题、列表、强调等以直观符号书写，脚本部分以 `#` 进入代码模式，函数调用与字典配置的形态统一。对多数仅需按给定规范完成论文的作者而言，Typst 的入门路径更短。

编译与预览方面，LaTeX 的全量编译在长文档上往往以十秒乃至分钟计，`latexmk -pvc` 虽可实现自动重编译，反馈仍属批处理模式；Typst 的增量编译使常见的局部修改在亚秒级完成重排，配合 `typst watch` 或编辑器侧栏预览，可获得接近边写边看的交互体验，有利于长周期撰稿。

生态与能力分布方面，LaTeX 的优势很大程度上来自 CTAN 生态：字体、算法、化学、绘图等方向均有成熟宏包，组合自由，但伴随版本与依赖管理成本；Typst 的标准库覆盖面更为集中，公式、文献、引用、表格、脚注等能力内建，复杂版式由模板包提供，特殊计算与解析可通过 WASM 插件接入外部实现。就国科大学位论文而言，封面、页眉页脚、双语题注与 GB/T 7714 参考文献等需求已由本模板封装，作者通常只需配置 `info` 并撰写正文。

可编程性方面，LaTeX 宏的本质是文本替换与展开，条件与循环的语义较为曲折，TeX/LaTeX3 层面的编程门槛较高；Typst 内置一门小型脚本语言，支持字典、数组、闭包与 `context` 机制，模板作者能够以接近常规程序设计的方式组织配置逻辑，本模板的 `documentclass` 函数即按此方式实现。对论文作者而言，配置项更为集中，错误信息更可读，调整单项样式时也无需在导言区堆叠宏包选项。

版面模型与诊断方面，LaTeX 的盒子与胶水模型表达能力强，但断行、断页与浮动体的位置有时难以预期，嵌套宏产生的错误信息也可能远离问题根源；Typst 采用更为结构化的布局原语（如 `block`、`grid`、`place`、`pagebreak`），提供带上下文的诊断信息，并在布局不收敛时给出明确警告。需要说明的是，Typst 仍处于快速演进阶段，部分排版细节与 TeX 并非逐像素一致；本模板在实现时已对照《指导意见》与参考样张对常用版式进行校准。

从 LaTeX 迁移到本模板的成本有限：导言区中的文档类与宏包选项大体对应 `documentclass(...)` 的参数，即论文元信息（题目、作者、导师、专业等）与 `twoside`、`anonymous` 等模式开关；`\input{chapter}` 式的章节组织对应主文件中的章节划分或 `#include`。作者随后按学位论文的物理顺序调用 `cover`、`decl-page`、`abstract` 等页面函数，并以 `#show:` 切换 `preface`、`mainmatter`、`appendix` 等布局即可，正文写作以 Markdown 式标记为主，无需掌握 Typst 的全部语法。

== 系统要求<sec:system>

前文所述的增量编译与实时预览，需要具体的运行环境支撑。Typst 官方支持 Windows、macOS 与 Linux，使用方式分为本地与网页两类，学位论文撰写推荐本地方案。本地方案以 Typst CLI 为核心，并搭配 VS Code、Neovim、Emacs 等编辑器的官方或社区扩展，以获得语法高亮、自动补全、定义跳转与侧边预览等语言服务；安装包请通过官方发布页或系统包管理器获取，避免非官方渠道构建带来的兼容问题。网页版 #link("https://typst.app/")[Typst Web App] 是无需本地安装的替代途径：在浏览器中即可在线编辑与实时预览，并支持多人协作，适合正式撰写前的快速试用；使用本模板时需手动上传 `fonts/` 目录下的字体文件，否则相应字体无法正常显示。

在本地方案中，CLI 提供 `compile`（单次编译）与 `watch`（监听变更并自动重编译）两种常用模式：撰写阶段通常使用 `watch`，并以 `--font-path` 指定本模板的 `fonts/` 目录，具体命令与项目组织见第2章。各环境的界面、编译方式、预览方案与语言服务等方面的对比见表 @tbl:Typst_intro。

// @typstyle off
#auto-table(
  caption-zh: [常见的 Typst 编译与编辑环境],
  caption-en: [Common Typst Compilation and Editing Environments],
  columns: 5,
  align: center,
  header: ([名称], [界面], [编译方式], [预览方案], [增量编译]),
  label: <Typst_intro>,
  [VS Code], [VS Code], [本地 CLI], [扩展 Webview], [watch 下是],
  [Neovim], [Neovim], [本地 CLI], [插件/Webview], [watch 下是],
  [Emacs], [Emacs], [本地 CLI], [插件/Webview], [watch 下是],
  [CLI], [任意编辑器], [本地原生], [外部阅读器], [watch 下是],
  [Web App], [浏览器], [云端/WASM], [内置实时预览], [是]
)

= Typst使用说明<chap:guide>

为了方便使用并更好地展示Typst的现代排版特性，本模板框架和文件结构经过精细设计，尽可能模块化各个功能和板块，以方便用户进行高效编辑。

== 项目结构简介

=== 编译方法

Typst CLI 提供两种编译方式：

(a) `compile`：用于单次编译生成 PDF；

(b) `watch`：持续监听文件变更并自动重新编译。

本模板需配置并使用 `fonts/` 目录下的字体，可通过 `--font-path` 选项指定，即：```bash typst compile template/thesis.typ --root . --font-path fonts```。其中 `--root .` 将项目根目录设为编译根（必需，否则相对导入会越界报错）。此外，`--open` 选项可在编译完成后自动打开 PDF，输出路径直接写在输入之后。


=== 项目根目录

(a) `lib.typ`：模板库入口文件，定义了 `documentclass` 函数，用于配置文档类型、字体、论文信息等全局参数。

(b) `typst.toml`：包配置文件，声明模板名称、版本、入口与编译器版本要求等元数据。

(c) `README.md`：模板说明文档。

(d) `LICENSE`：开源许可证文件。

(e) `Makefile`：辅助任务脚本，提供格式化（`format`）、格式检查（`format-check`）、包检查（`lint-quick`）与清理（`clean`）等目标；编译本身由 Typst CLI 完成。

(f) `format-typst.sh`：代码格式化脚本。

=== template 文件夹

存放论文主文件及章节内容，是撰写论文时主要关注和修改的位置。当前结构仅供参考，用户可按个人习惯自由组织。

(a) `thesis.typ`：论文主文件，包含文档配置、页面生成及章节引用。

(b) `ref.bib`：参考文献数据库文件

(c) `images/`：图片资源目录


=== layouts 文件夹

包含文档布局定义文件，控制论文各部分的页面布局。

(a) `doc.typ`：文档整体布局设置，包含页面尺寸、页边距、页眉页脚等。

(b) `preface.typ`：前言部分布局（摘要、目录等）。

(c) `mainmatter.typ`：正文部分布局。

(d) `appendix.typ`：附录部分布局。

=== pages 文件夹

包含各类页面的具体实现，如封面、声明、摘要等。

(a) `master-cover.typ` / `bachelor-cover.typ`：研究生/本科生封面页。

(b) `master-decl-page.typ` / `bachelor-decl-page.typ`：研究生/本科生声明页。

(c) `master-abstract.typ` / `bachelor-abstract.typ`：中文摘要页。

(d) `master-abstract-en.typ` / `bachelor-abstract-en.typ`：英文摘要页。

(e) `outline-page.typ`：目录页。

(f) `list-of-figures-and-tables.typ`：图表目录页。

(g) `notation.typ`：符号表页。

(h) `acknowledgement.typ`：致谢页。

(i) `backmatter.typ`：后置部分（作者简历、学术成果等）。

(j) `fonts-display-page.typ`：字体展示测试页。

(k) `degree-table.typ`：学位类别中英文对照表（规范附件 2，无编号展示性表格，置于附录等处）。

=== utils 文件夹

包含各类工具函数和辅助模块。

(a) `bilingual-bibliography.typ`：双语参考文献处理。

(b) `custom-figure.typ`：模板内双语图表封装（`bifigure`, `bitable`，供论文正文直接调用）。

(c) `bilingual-figured.typ`：通用图表编号/双语标题引擎。

(d) `continued-table.typ`：续表工具（统一提供 `auto-table` 自动续表与 `continued-table` 手动续表）。

(e) `aligned-equation.typ`：多行对齐公式。

(f) `custom-numbering.typ`：自定义章节编号样式。

(g) `style.typ`：字体和样式定义。

(h) `page-foreground.typ`：前言/正文页眉页脚 foreground 工厂（奇数页章名、偶数页题目，页脚页码距页边界 1.5cm 绝对定位）。

(i) `supervisor.typ`：导师信息统一数据结构与中英文渲染。

(j) `invisible-heading.typ`：目录收录用的不可见标题。

(k) `citation-range-hyphen.typ`：顺序编码制引用连续序号的连字符修正。

(l) `datetime-display.typ`：日期格式化显示。

(m) `justify-text.typ`：表格中文标签的双端对齐。

(n) 其他小型工具：`double-underline.typ`（双下划线）、`hline.typ`（水平横线）、`unpairs.typ`（键值数组转字典）。

=== 其他文件夹

`fonts` 存放模板所需的字体文件，包括宋体、黑体、楷体、Times New Roman 等。编译时需通过 `--font-path` 指定此目录。

`assets` 文件夹存放模板使用的静态资源，如校徽 `ucas-emblem.svg` 等视觉标识素材。

`docs` 文件夹存放模板的相关文档，如定制指南（CUSTOMIZE）、撰写规范摘录（RULES-GRAD、RULES-BACHELOR）、版权声明与常见问题等。

`tests` 文件夹存放回归测试，如双语参考文献转换测试（`bilingual-transform.typ`）。

`others` 文件夹存放独立的开题报告模板（本科/硕士），不经 `documentclass` 组装，与主模板相互独立。

== 数学公式

(a) 基本书写。行内公式以 `$...$` 书写，如 $x + y$、$a_i^2 + b_i^2$；行间公式（`$ x $` 两侧至少各有一个空格或换行）独立成段书写，模板自动按章编号（形如 (1-1)）：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用按章节编号的公式需加 `eqt:` 前缀。量词默认由作者手写（如"式 (2-1)"，便于连续引用如"式 (1-1)～(1-3)"，或改用"公式 (1-2)"等措辞）；如需自动补全，可在 `documentclass` 中设置 `ref-supplements` 参数。由式 @eqt:ratio 可得 Fibonacci 数列的闭式：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

不需要编号的行间公式以 `<->` 标注，且不影响后续公式的编号：

$ y = integral_1^2 x^2 dif x $ <->

$ F_(n+1) = F_n + F_(n-1) $

(b) 常用结构。上下标按手写习惯书写（如 `x_i^2`），斜线 `/` 自动排版为分式（如 `a/(b+c)`），求和、积分、极限的上下限以 `_` 与 `^` 附加，微分 `dif` 自动排为正体，组合数由 `binom` 得到；符号以名称书写（如 alpha、nabla、oo），部分符号提供别名（如 phi.alt 为 φ 的变体形）：

$
  sum_(k=0)^n binom(n, k) = 2^n, quad integral_(-oo)^(+oo) e^(-x^2) dif x = sqrt(pi), quad lim_(x -> 0) (sin x)/x = 1
$

(c) 矩阵与向量。矩阵以 `mat` 书写，行内元素以逗号分隔、行间以分号分隔；定界符默认为圆括号，可经 `delim` 参数更换（如 `#set math.mat(delim: "[")` 全局改为方括号）：

$ bold(A) bold(x) = bold(b), quad A = mat(a, b, c; d, e, f; g, h, i) $

向量与张量按惯例以粗体表示，直接书写 `bold(V)`、`bold(sigma)`；需要正体粗体（LaTeX `\mathbf` 风格）时可用 `bold(upright(V))`。

(d) 分段函数与方程组。`cases` 以逗号分隔各分支、以 `&` 对齐分支内容，分支内部的逗号须转义为 `\,`；定界符默认为花括号，可经 `delim` 更换，`reverse: true` 时分支朝右展开。以 Navier–Stokes 方程组为例，各守恒律占一行；若单行仍过宽，可在运算符后转行：

$
  cases(
    (partial rho)/(partial t) + nabla dot (rho bold(V)) = 0,
    (partial (rho bold(V)))/(partial t) + nabla dot (rho bold(V) bold(V))
    = nabla dot bold(sigma),
    (partial (rho E))/(partial t) + nabla dot (rho E bold(V))
    = nabla dot (k nabla T) + nabla dot (bold(sigma) dot bold(V)),
  )
$

(e) 定界符。成对括号默认随内容高度自动缩放；需要精确控制时可用 `lr`（`size` 参数指定相对高度），绝对值、范数、取整等有专用函数 `abs`、`norm`、`floor`、`ceil`：

$ abs((x + y) / 2), quad norm(x)_2, quad ceil(x/2) $

(f) 多行公式。较长的数学公式如必须分行书写，按《指导意见》要求只能在 `+ - × ÷ ＜ ＞` 等运算符之后转行，且序号编于最后一行右顶格。使用 `aligned-equation` 可将编号对齐到最后一行右侧：

#aligned-equation[$
  f(x) & = a x^2 + b x + c \
       & = a(x^2 + b/a x) + c \
       & = a(x + b/(2a))^2 + c - b^2/(4a)
$] <quadratic>

由式 @eqt:quadratic 可知，任意二次函数都可以化为顶点式。

(g) 修饰符与上下标注。向量、均值、估计量等常用记号由 `vec`、`hat`、`bar`、`tilde`、`dot`、`accent` 等函数附加（双重点号用 `accent(x, dot.double)`）：

$
  bold(v) = vec(v_x, v_y), quad hat(n), quad bar(x), quad tilde(f), quad dot(x), quad accent(x, dot.double)
$

需要在表达式上下方加注释时，可用 `underbrace` 与 `overbrace`；推导过程中划去相消项用 `cancel`。数学模式内的中文不会自动继承正文字体，须用 `#text(font: ...)` 显式指定含 CJK 的字体列表，否则会因数学字体缺字而显示为空框：

$
  underbrace(a + b + c, #text(font: ("Times New Roman", "Songti SC", "SimSun", "FandolSong"))[求和项]) = overbrace((a + b) + c, #text(font: ("Times New Roman", "Songti SC", "SimSun", "FandolSong"))[结合]), quad
  (x + y) - cancel(y) = x
$

(h) 多字母名称与算子。公式内的多字母名称与单位以引号书写为正体文字（如 $m_"air" = 1.2 "kg"$）；字体变体由 `bold`、`upright`、`cal`、`frak`、`mono` 等函数控制。自定义算子以 `op` 书写，可带上下限：

$ op("argmax")_(x in Omega) f(x), quad op("Re", limits: #false) z $

完整符号表见官方文档 #link("https://typst.app/docs/reference/symbols/")[Symbols]；与 LaTeX `amsmath` 的对应关系见 #link("https://typst.app/docs/guides/for-latex-users/")[Guide for LaTeX Users]。

== 数学环境

模板内置与 LaTeX `amsthm` 对应的定理类环境。公理、定理、引理、推论、断言、命题、猜想共用计数器；定义与例各自计数；注不编号；证明以黑色方框结束。编号随章清零，形如「定理 1-1」「定理 2-1」。可选参数 `name` 在编号后附加括号题名，正文用方括号书写。交叉引用时标签须带种类前缀：定理 `thm:`、公理 `axm:`、引理 `lem:`、推论 `cor:`、断言 `ast:`、命题 `prp:`、猜想 `cnj:`、定义 `def:`、例 `ex:`（注与证明不编号，不接受标签）。引用处量词默认由作者手写（如「定理 2-2」），可在 `documentclass` 中以 `ref-supplements` 参数开启自动补全：

#axiom[这是一个公理。]
#theorem(
  name: "勾股",
)[直角三角形两直角边的平方和等于斜边的平方，即 $a^2 + b^2 = c^2$。] <thm:gougu>
#lemma[这是一个引理。] <lem:demo>
#corollary[这是一个推论。]
#assertion[这是一个断言。]
#proposition[这是一个命题。]
#conjecture[这是一个猜想。]
#definition(
  name: "Fibonacci 数列",
)[数列 $F_n$ 满足 $F_0 = 0$，$F_1 = 1$，且对 $n >= 2$ 有 $F_n = F_(n-1) + F_(n-2)$。] <def:fib>
#example[由定义 @def:fib，$F_2 = 1$，$F_3 = 2$，$F_4 = 3$。] <ex:fib2>
#remark[这是一个注。]

#proof[
  由式 @eqt:ratio 及数学归纳法可得 Fibonacci 数列的通项公式，此处从略。
]

定理、引理、定义、例可分别引用，如定理 @thm:gougu、引理 @lem:demo、定义 @def:fib、例 @ex:fib2。若需自定义标题用词、按节编号、改计数规则或增减引用前缀，可修改 `utils/theorem.typ`（引用前缀见 `_thm-refspec`）；一般写作直接使用上列函数即可。

== 图片

论文中的插图通常分为单图与多图。模板统一使用 `bifigure` 生成双语题注，并默认按章编号。交叉引用时标签须带类型前缀：图 `fig:`、表 `tbl:`、公式 `eqt:`（前缀只用于区分标签类型，本身不渲染）。引用处显示的「图」「表」「式」等量词默认由作者手写（如「图 2-1」），可在 `documentclass` 中以 `ref-supplements` 参数开启自动补全。双语题注样式由 `utils/custom-figure.typ` 中的 `thesis-bilingual-caption-style` 统一配置。

(a) 单图

`bifigure` 基于原生 `figure` 封装，支持 `caption-zh` / `caption-en` 与 `note`。常用位图与矢量格式均可：`png`、`jpg`、`webp`、`svg`，以及单页 `pdf`。宽度用相对版心的比例书写，便于统一缩放：

#bifigure(
  image("images/ucas-emblem.svg", width: 10%),
  caption-zh: [中国科学院],
  caption-en: [Chinese Academy of Sciences],
) <ucasLogo>

如图 @fig:ucasLogo 所示。

(b) 图片裁剪

若原图四周留白过大，不必先改源文件，可用 `box(clip: true)` 在排版阶段裁切：把图片放到略大的尺寸，再用 `move` 平移，使目标区域落入固定宽高的视口，窗外内容被裁掉。下列示例把 100pt 宽的图片放入 80pt×60pt 的视口并左移 10pt、上移 8pt：

#bifigure(
  box(
    clip: true,
    width: 80pt,
    height: 60pt,
    move(
      dx: -10pt,
      dy: -8pt,
      image("images/ucas-emblem.svg", width: 100pt),
    ),
  ),
  caption-zh: [裁切视口示例],
  caption-en: [Cropped Viewport Example],
) <crop-demo>

也可用 ImageMagick 等工具预先裁好再插入，二者效果等价；批量处理或留白不规则时，预裁更直观。

(c) 多图

多图用 `grid` 排列，每个子图仍用 `bifigure` 以保持独立编号与双语题注。子图题注宜简短，细节说明写入 `note` 或主叙述；子图通过 `note` 添加的注释以「注：」开头。例如：

#align(center)[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 1em,
    [#bifigure(
      image("images/ucas-emblem.svg", width: 18%),
      caption-zh: [子图甲],
      caption-en: [Subfigure A],
    ) <subfig-a>],
    [#bifigure(
      image("images/ucas-emblem.svg", width: 28%),
      caption-zh: [子图乙],
      caption-en: [Subfigure B],
      note: [与子图甲使用同一矢量源，仅宽度不同。],
    ) <subfig-b>],
  )
]

子图可分别引用（图 @fig:subfig-a、图 @fig:subfig-b），也可在正文中合并叙述。

== 表格

学位论文中的表格以三线表为主。模板提供 `bitable`（原生 `table` 的双语封装，可与 `table.header`、`table.cell`、`table.hline` 等 API 组合）与 `auto-table`（自动跨页续表）。下列并排示例分别演示全边框网格表与三线表：

#align(center, (
  stack(dir: ltr)[
    #bitable(
      table(
        align: center + horizon,
        columns: 4,
        [t], [1], [2], [3],
        [y], [0.3s], [0.4s], [0.8s],
      ),
      caption-zh: [常规表],
      caption-en: [Regular Table],
    ) <timing>
  ][
    #h(50pt)
  ][
    // @typstyle off
    #bitable(
      table(
        columns: 4,
        stroke: none,
        table.hline(),
        [t], [1], [2], [3],
        table.hline(stroke: .5pt),
        [y], [0.3s], [0.4s], [0.8s],
        table.hline(),
      ),
      caption-zh: [三线表],
      caption-en: [Three-line Table],
    ) <timing-tlt>
  ]
))

#bitable(
  table(
    columns: 3,
    align: center,
    table.header([项目], [数值], [单位]),
    [A], [10.5], [cm],
    [B], [20.3], [kg],
    [C], [15.2], [m/s],
  ),
  caption-zh: [带注释的实验数据表],
  caption-en: [Experimental Data Table with Note],
  note: [所有数值均为三次测量的平均值。],
) <with-note>

上述表示例可通过表 @tbl:timing、表 @tbl:timing-tlt 与表 @tbl:with-note 引用。

=== 自动续表

当表格数据较多需要跨页时，使用 `auto-table` 可以自动在续页显示"续表"标记和表头。
`auto-table` 会主动采用可分页渲染，因此不受 `bitable` 默认 `keep_together: true` 的防跨页约束，适合长表。

#let regional-base = (
  ([北京], [41611], [5.2], [2184], [190580]),
  ([上海], [47218], [5.0], [2487], [189880]),
  ([广东], [135010], [4.8], [12701], [106310]),
  ([江苏], [128222], [5.8], [8515], [150520]),
  ([浙江], [82553], [6.0], [6577], [125520]),
  ([山东], [92069], [5.5], [10163], [90590]),
  ([四川], [60133], [5.8], [8372], [71830]),
  ([湖北], [55803], [5.6], [5775], [96620]),
  ([福建], [54355], [5.1], [4188], [129800]),
  ([湖南], [50015], [4.9], [6622], [75530]),
  ([河北], [36137], [5.3], [5665], [64280]),
  ([安徽], [38728], [5.7], [5142], [70820]),
  ([河南], [48206], [5.4], [6478], [71050]),
  ([广西], [23778], [4.6], [3038], [49320]),
  ([江西], [26907], [5.0], [3481], [77230]),
  ([山西], [23134], [5.1], [3056], [49780]),
)

#let regional-rows = ()
#for round in range(1, 6) {
  for row in regional-base {
    regional-rows.push(row.at(0))
    regional-rows.push(row.at(1))
    regional-rows.push(row.at(2))
    regional-rows.push(row.at(3))
    regional-rows.push(row.at(4))
  }
}

// @typstyle off
#auto-table(
  caption-zh: [各地区经济指标],
  caption-en: [Regional Economic Indicators],
  columns: 5,
  align: center,
  stroke: none,
  header: (
    table.hline(), [地区], [GDP（亿元）], [增长率（%）], [人口（万）], [人均GDP（元）],
    table.hline(stroke: .5pt),
  ),
  label: <regional>,
  ..regional-rows,
  table.hline(),
)

自动续表示例可通过表 @tbl:regional 引用。

=== 手动续表

如果不启用自动续表，或希望精确控制续表位置，可以使用 `continued-table`：

// 先创建原表
#bitable(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [项目], [测试组], [数值], [单位],
    table.hline(stroke: .5pt),
    [A], [I], [10.5], [cm],
    [B], [I], [20.3], [kg],
    [C], [I], [15.2], [m/s],
    [D], [I], [8.7], [kg],
    table.hline(),
  ),
  caption-zh: [实验数据],
  caption-en: [Experimental Data],
) <manual-continued>

// 手动续表
#continued-table(
  <tbl:manual-continued>,
  align(center)[
    #table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      stroke: none,
      table.hline(),
      [项目], [测试组], [数值], [单位],
      table.hline(stroke: .5pt),
      [E], [II], [11.8], [cm],
      [F], [II], [19.6], [kg],
      [G], [II], [14.1], [m/s],
      [H], [II], [9.2], [kg],
      table.hline(),
    )
  ],
  note: [续表数据为补充实验结果。],
)

原表可通过表 @tbl:manual-continued 引用。

=== 卧排表

当表格列数较多、横向宽度超出版心时，可使用 `landscape: true` 将整表逆时针旋转 90°，使表顶朝页面左侧、表底朝右侧，符合《撰写规范》"顶左底右"的方位要求（见表 @tbl:landscape-table）。卧排表不跨页，应控制在一页之内；其标题与注释随表格一同旋转，方位保持一致。`bitable` 与 `auto-table` 均支持该参数。

#bitable(
  table(
    columns: 7 * (auto,),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [序号], [样本编号], [测量项目], [测量值], [单位], [方法], [备注],
    table.hline(stroke: .5pt),
    [1], [S-001], [长度], [12.45], [cm], [游标卡尺], [室温],
    [2], [S-002], [质量], [34.80], [g], [电子天平], [三次平均],
    [3], [S-003], [温度], [25.3], [℃], [热电偶], [稳态读数],
    [4], [S-004], [压强], [101.3], [kPa], [气压计], [海拔修正],
    [5], [S-005], [频率], [50.0], [Hz], [频率计], [市电标称],
    table.hline(),
  ),
  caption-zh: [多列宽表（卧排）],
  caption-en: [Wide Multi-column Table (Landscape)],
  landscape: true,
) <landscape-table>

卧排表可通过表 @tbl:landscape-table 引用，引用文本仍按常规横排渲染。

== 参考文献

本模板默认采用顺序编码制（GB/T 7714—2015 numeric）：正文引用为上标序号，文末文献表由 `bilingual-bibliography` 生成。其中英文条目的"卷 / 版 / 等"会自动转为 `Vol.` / `ed.` / `et al.`，中英文混排无需手工处理。

(a) 引用步骤

写引用的过程分两步：先把文献条目写入 `template/ref.bib`，再在正文中引用。

第一步，将 BibTeX 条目写入 `template/ref.bib`（也可从 Zotero、EndNote 等导出）。`@book` 后花括号里的名字即引用键（下例的 `jiang1998`），全文用它引用该条目；引用键建议只用拉丁字母与数字，避免特殊字符：

```typ
@book{jiang1998,
  title={中国森林群落分类及其群落学特征},
  author={蒋有绪 and 郭泉水 and 马娟 and others},
  year={1998},
  publisher={科学出版社},
  address={北京},
  pages={11-12},
}
```

第二步，在正文中用 `@key` 引用，或显式调用 `#cite(<key>)`。`@key` 后面紧跟中文时，要用 `#[]` 把引用包起来或加一个空格隔开，否则后面的中文会被误认成标签的一部分。主文件已通过 `bibliography: bibliography.with("ref.bib")` 接好数据源；文末 `#bilingual-bibliography(full: true)` 负责排印文献表，`full: true` 表示列出库中全部条目（含未引用文献），若只需列出被引用条目，改为 `full: false`。

(b) 引用形式

单篇引用直接写 `@key`，序号自动上标：图书#[@jiang1998]和会议#[@cstam1990]。

同一处引用多篇时，把多个 `@key` 紧邻书写，CSL 自动合并：序号不连续时以英文逗号分隔（@jiang1998@cstam1990），连续时以短横线连接（@jiang1998@cstam1990@WHO1970）。不要用分号手动拼接。

叙述式引用（类似 LaTeX 的 `\citet` / `\textcite`，如"蒋有绪等[1]指出"）在顺序编码制下不用特殊形式，直接手写作者、后面跟一个常规引用即可，例如蒋有绪等#[@jiang1998]曾对中国森林群落类型作过系统划分。`form: "prose"` 与 `"author"` 会按 CSL 把全部作者列出来，只适合著者—出版年制；顺序编码制下如果只要年份，可用 `form: "year"`。角标里是否显示页码等补充信息由 CSL 样式决定；顺序编码制一般只在文末文献表中给出页码。

(c) 样式切换

`bilingual-bibliography` 的 `style` 默认为 `"gb-7714-2015-numeric"`。若培养单位要求著者—出版年制，可改为：

```typ
#bilingual-bibliography(full: true, style: "gb-7714-2015-author-date")
```

注意：author-date 路径目前仅做语法演示，续行缩进与著录细节尚未对照规范实测；国科大正文通常使用顺序编码制。更完整的样式列表见官方 #link("https://typst.app/docs/reference/model/bibliography/")[bibliography] 文档。

== 代码块

代码以三反引号书写，紧随其后的语言标签启用语法高亮；行内代码用单反引号。`lang` 支持 `py`、`rust`、`c`、`typ` 等常见标签。

(a) 带题注的代码

用原生 `figure` 包裹代码块即可编号与引用（@code）：

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [代码块],
) <code>

(b) 行号与配色

行号可在文档开头用 `show` 规则统一打开；配色主题通过 `set raw(theme: ...)` 指定，`none` 关闭高亮。下列规则演示为所有代码块添加行号：

```typ
#show raw.line: it => grid(
  columns: (2em, 1fr),
  align: (right, left),
  text(fill: luma(120), str(it.number)),
  it.body,
)
```

(c) 伪代码与算法

论文中的算法伪代码可用代码块书写（如 `lang: "text"` 或 `python`），需要专业排版时可引入社区包（如 `@preview/algo`、`@preview/lovelace`）；一般实验步骤与简短过程用模板自带的高亮代码块即可满足。

= 中国科学院大学研究生学位论文撰写规范指导意见（节选）<chap:ucas>

学位论文是研究生在掌握已有的科学知识的基础上，运用科学思维和一定的科学方法、技术与工具，面向特定的科学领域所存在的科学问题，开展创新性研究而产生的科学研究成果。

学位论文是研究生科研工作成果的集中体现，是评判学位申请者学术水平、授予其学位的主要依据，是科研领域重要的文献资料。撰写学位论文是对研究生科学研究能力的基本训练，是研究生学业与研究成效的基本检验，也是科研与创新能力的重要体现。

为提高研究生学位论文的撰写质量，促进学位论文在内容和格式上的规范化，参照《学位论文编写规则》（GB/T 7713.1—2006）、《信息与文献 参考文献著录规则》（GB/T 7714—2015）和《学术出版规范
期刊学术不端行为界定》（CY/T
174—2019）等国家有关标准，特制定本指导意见（2021年修订）。各学科群学位评定分委员会（以下简称各学科群分会）可结合本学科领域的特点，参考本指导意见，制订符合本学科领域特点与要求的学位论文撰写具体要求。

本指导意见从2023年冬季批次开始实施。

== 组成及要求

学位论文一般由以下几个部分组成：封面、原创性声明及授权使用声明、摘要、目录、符号说明（若有）、正文、参考文献、附录（若有）、致谢、作者简历及攻读学位期间发表的学术论文与其他相关学术成果等。

=== 封面

一律采用中国科学院大学规定的统一中英文封面，封面包含内容如下：

（1）密级，涉密或延迟公开论文必须在论文封面标注密级，同时注明保密年限。公开论文不标注密级，可删除此行。

（2）论文题目，应简明扼要地概括和反映整个论文的核心内容，一般不宜超过25个汉字（符），英文题目一般不应超过150个字母，必要时可加副标题。题目中应尽量避免使用缩略词、首字母缩写词、字符、代号和公式等。

（3）作者姓名，根据《中国人名汉语拼音字母拼写规则》（GB/T 28039—2011），英文封面中的姓和名分写，姓在前，名在后，姓名之间用空格分开。姓和名需写全拼，姓全大写，名首字母大写。外国留学生姓名书写顺序以护照格式为准，字母全部大写。

（4）指导教师，需同时填写导师姓名、专业技术职务和工作单位。如果有多位导师（均需经培养单位批准，并在学籍系统备案），第一导师在前，第二导师等依次在后。学位论文在指导小组的指导下完成的，应注明指导小组成员相应信息。

（5）学位类别，包括学科门类（学术型）或专业学位类别以及学位级别。学科门类如理学、医学等，专业学位类别如应用统计、工商管理等。学位级别包括硕士、博士。

（6）学科专业，填写攻读学位的一级学科/二级学科或专业学位类别/领域全称，须与学籍信息一致，不可用简写。

（7）培养单位，填写就读研究所或学院、系全称，如中国科学院××研究所、中国科学院大学××学院。

（8）时间，填写论文提交学位授予单位的年月，使用阿拉伯数字标注。一般夏季申请学位的论文标注6月，冬季申请学位的论文标注12月。例如：2023年6月，2023年12月。

=== 原创性声明及授权使用声明

本部分内容提供统一的模版，提交时作者和导师须亲笔签名。如遇导师无法签字时，培养单位应做出适当处理。

=== 摘要和关键词

论文摘要包括中文摘要和英文摘要（Abstract）两部分。论文摘要应概括地反映出本论文的主要内容，说明本论文的主要研究目的、内容、方法、结论。要突出本论文的创造性成果或新见解，不宜使用公式、图表、表格或其他插图材料，不标注引用文献。中文摘要的字数由各学科群分会根据本分会涉及学科专业的特点提出具体要求。英文摘要与中文摘要内容应保持一致。留学生用其他语种撰写学位论文时，应有详细的中文摘要，字数由各学科群分会具体制定，建议一般不少于5000字。

摘要最后注明本文的关键词（3～5个）。关键词是为了文献标引和检索工作，从论文中选取出来，用以表示全文主题内容信息的单词或术语。关键词以显著的字符另起一行并隔行排列于摘要下方，左顶格，中文关键词间用中文逗号隔开。英文关键词应与中文关键词对应，首字母应大写，用英文逗号隔开。

摘要应另起一页，与正文前的内容连续编页（用罗马字符）。

=== 目录

目录应包括论文正文中的全部内容的标题，以及参考文献、附录（若有）和致谢等，不包括中英文摘要。目录页由论文的章、条、附录等序号、名称和页码组成。正文章节题名要求最多编到第三级标题，即×.×.×（如1.1.1）。一级标题顶格书写，二级标题缩进一个汉字符位置，三级标题缩进两个汉字符位置。论文中若有图表，应有图表目录，置于目录页之后，另页编排。图表目录应有序号、图题或表题和页码。

目录应另起一页，与正文前的内容连续编页（用罗马字符）。

=== 符号说明（若有）

如果论文中使用了大量的物理量符号、标志、缩略词、专门计量单位、自定义名词和术语等，应编写成注释说明汇集表。若上述符号等使用数量不多，可以不设此部分，但必须在论文中首次出现时加以说明。
论文中若有符号说明，应置于目录之后、正文之前，另起一页，与正文前的内容连续编页（用罗马字符）。

=== 正文
正文一般包括绪论、论文主体、研究结论与展望等部分。

（1）绪论应包括选题的背景和意义，国内外相关研究成果与进展述评，本论文所要解决的科学与技术问题、所运用的主要理论和方法、基本思路和论文结构等。绪论应独立成章，用足够的文字叙述，不与摘要雷同。要实事求是，不夸大也不弱化前人的工作和自己的工作。

（2）论文主体是正文的核心部分，占主要篇幅，它是将学习和研究过程中调查、观察和测试所获得的材料和数据，经过思考判断、加工整理和分析研究，进而形成论点。依据学科专业及具体选题，论文主体可以有不同的表现形式，可以按照章与节的结构表述，也可以按照“研究背景与意义—研究方法与过程—研究结果与讨论”的表述形式组织论文。但主体内容必须实事求是，客观诚实，准确完备，合乎逻辑，层次分明，简明可读。

（3）研究结论是对整个论文主要成果的总结，不是正文中各章小结的简单重复，应准确、完整、明确、精炼。应明确凝练出本研究的主要创新点，对论文的学术价值和应用价值等加以分析和评价，说明本项研究的局限性或研究中尚难解决的问题，并提出今后进一步在本研究方向进行研究工作的设想或建议。结论部分应严格区分本人研究成果与他人科研成果的界限。

=== 参考文献

本着严谨求实的科学态度撰写论文，凡学位论文中有引用或参考、借鉴他人思想或成果之处，均应按一定的引用规范，列于文末（通篇正文之后），参考文献部分应与正文的文献引用一一对应，注重合理引用，严禁抄袭剽窃等学术不端行为。

=== 附录（若有）

主要列入正文内过分冗长的公式推导、供查读方便所需的辅助性数学工具或表格、数据图表、程序全文及说明、调查问卷、实验说明等。

=== 致谢

对给予各类资助、指导和协助完成研究工作，以及提供各种对论文工作有利条件的单位及个人表示感谢。致谢应实事求是，切忌浮夸与庸俗之词。致谢末尾应具日期，日期与论文封面一致。

=== 作者简历及攻读学位期间发表的学术论文与其他相关学术成果

作者简历应包括从大学起到申请学位时的个人学习工作经历。按学术论文发表的时间顺序，列出作者本人在攻读学位期间发表或已录用的学术论文清单（著录格式同参考文献）。其他相关学术成果可以是申请的专利、获得的奖项及完成的项目等代表本人学术成就的各类成果。

== 撰写要求

=== 学位论文基本要求

学位论文必须是一篇系统的、完整的学术论文，遵循既定的学术规范与要求，不仅要符合学位论文的形式规范，更要符合学位论文的质量规范。做到：学术观点明确，立论正确，方法科学，材料翔实，数据可靠，推理严谨，论证充分，引用规范，结构合理，层次分明，文字通顺，表达准确，学风严谨。研究成果体现作者独到的学术见解、科学论证与创新性结论，表明作者掌握了坚实的基础理论和系统的专门知识，具有独立地从事科学研究的能力。

硕士学位论文选题应为本学科重要领域，有一定的理论意义或应用价值；在理论或方法上有一定的创新，解决了科学或生产实践中某一项重要的问题，取得重要的研究成果，具有较好的社会效益或应用前景。

博士学位论文选题应为本学科前沿领域，有重要的理论意义或应用价值；在理论或方法上有较大的创新，解决了科学或生产实践中某一项重大的问题，取得突破性的研究成果，具有重要的社会效益或应用前景。

=== 论文原创性要求

学位论文应为学位申请者在导师的指导下独立完成的科学研究成果，为作者本人的原创性成果，系研究生经过多年的专业学习和科学研究，运用科学思维、科学方法或工具，探索科学领域中的某一科学问题，提出问题，分析问题，解决问题。学位论文中要有清晰完整的文献综述，但不能以文献综述来代替学位论文。论文引用规范合理，没有伪造、篡改、剽窃、他人代写、论文买卖及其它学术不端行为。

=== 论文创新性要求

学位论文的研究既包括创造知识，即创新、发现和发明，是对未知世界及其规律的探索，也包括整理知识，即对已有知识分析整理，使其规范化、系统化，是对已有知识的传承。创新活动，贯穿了学位论文研究与写作的全过程，如提出新的学术思想、科学概念、假说、学说、定理、定律，设计新的观察方法和实验手段，建立新的科学模型，研制出新的产品，设计出新的工艺流程，发现新的物种等。学位论文的价值在于探索未知，发现科学发展中的规律与特征。学位论文要体现其应有的严谨性与探索性，在原创性的基础上实现对已有知识的超越、突破或颠覆，发现前所未有的科学问题，提出前所未有的分析论证，得出前所未有的科学结论。

=== 学位论文的字数要求
学位论文最重要的意义在于其学术研究的创新性，应将学位论文的质量水平作为主要考量，不以字数多少作为特别要求，但各学科群分会可根据本领域涉及的学科专业特点做相应规定。

=== 文字、标点符号和数字

除外国来华留学生、外语专业研究生以及特殊需要外，学位论文一律用国家正式公布实施的简化汉字书写。标点符号的用法以《标点符号用法》（GB/T 15834—2011）为准。数字用法以《出版物上数字用法》（GB/T 15835—2011）为准。

外国来华留学生可用中文或英文撰写学位论文，但应有详细的中英文摘要。外语专业的学位论文应用所学专业相应的语言撰写，摘要应使用中文和所学专业相应的语言对照撰写。

为了便于国际合作与交流，中文学位论文亦可有英文或其他文字的副本。

=== 论文正文

（1）章节和各章标题

论文正文须由另页右页（奇数页）开始，用阿拉伯数字连续编码，一直到全文最后。正文内部新章节无须另页右页（奇数页）开始。
论文可参考“绪论-研究背景与意义-研究方法与过程-研究结果与讨论-研究结论与展望”的结构形式撰写，各主体研究内容可分别单独成为章节并作为章节标题使用。

各章标题中尽量不采用英文缩写词，对必须采用者，应使用本行业的通用缩写词。标题中尽量不使用标点符号。

（2）序号

标题序号：论文标题分层设序。层次以少为宜，根据实际需要选择。各层次标题一律用阿拉伯数字连续编号。以三级标题为宜，最多四级。若确需要再增加一级，以小括号形式表示；不同层次的数字之间用小圆点“.”相隔，末位数字后面不加点号，如“1.1”，“1.1.1”等；章的标题居中排版，各层次的序号均左起顶格排，序号与题名间空一个汉字符。

图表等编号：论文中的图、表、附注、公式、算式等，一律用阿拉伯数字分章依序连续编码。其标注形式应便于互相区别，如：图1-1（第1章第一个图）、图2-2（第2章第二个图）；表3-2（第3章第二个表）等。附录的图表参考正文的编号方式，如附图1-1或附表1-1。

页码：正文页码从绪论开始按阿拉伯数字（1，2，3……）连续编排，页码应位居左页左下角、右页右下角；正文前的部分（中英文摘要、目录等）用大写罗马数字（I，II，III…）单独编排，页码位于页面下方居中。

（3）页眉

页眉从摘要开始，奇数页上标明“摘要”、“Abstract”、“目录”、“图表目录”等，偶数页上标明论文题目（英文摘要标明英文题目）。正文（即第1章开始到最后一章）的页眉，奇数页上标明每一章名称，偶数页上标明论文题目。参考文献、附录、致谢等的页眉，奇数页标明“参考文献”、“附录”、“致谢”等，偶数页标明论文题目。页眉居中设置。

（4）名词和术语

科技名词术语及设备、元件的名称，应采用全国科学技术名词审定委员会公布的权威标准或其他相关权威信息源规定的术语或名称。标准中未规定的术语要采用行业通用术语或名称。全文名词术语必须统一。一些特殊名词或新名词应在适当位置加以说明或注解。双名法的生物学名部分均为拉丁文，并为斜体字。

采用英语缩写词时，除本行业广泛应用的通用缩写词外，文中第一次出现的缩写词应该用括号注明英文原词。新的外来名词应用括号注明英语全称和缩写语。

（5）量和单位

量和单位要严格执行《国际单位制及其应用》（GB 3100-93）、《有关量、单位和符号的一般原则》（GB3101—93）有关量和单位的规定。量的符号一般为单个拉丁字母或希腊字母，并一律采用斜体（pH例外）。

（6）图和表

论文中若有图和表，应设置图表目录，先列图后列表，置于目录页后，另页编排。

图：图片大小适当，图边界在页面范围内（图边界离页面边界距离大于页边距）。若图片中包含文字，文字大小不超过正文文字大小。图包括曲线图、构造图、示意图、框图、流程图、记录图、地图、照片等，宜插入正文适当位置。引用的图必须注明来源。具体要求如下：

- 图应具有“自明性”，即只看图、图题和图注，不阅读正文，就可理解图意。每一图应有简短确切的图题，连同图序置于图下居中。
- 图中的符号标记、代码及实验条件等，可用最简练的文字横排于图框内或图框外的某一部位作为图注说明，全文统一。图题建议用中文及英文两种文字表达。
- 照片图要求主要显示部分的轮廓鲜明，便于制版，如用放大、缩小的复制品，必须清晰，反差适中，照片上应有表示目的物尺寸的标尺。
- 图片一般设为高6cm×宽8cm，但高、宽也可根据图片量及排版需要按比例缩放。中文（宋体）英文（Times New Roman）图注为五号字，1.25倍行距。
- 文中尽量不用世界地图、全国地图！如果一定要用，凡涉国界图件（国内部分地区、全国、世界部分地区、全球）必须使用自然资源部标准地图底图（下载网址：http://bzdt.ch.mnr.gov.cn），所用底图边界要完全无修改（包括南海诸岛位置），为适应排版时图的缩放，比例尺一律用线段比例尺，而不用数字比例尺。并在图题下注明“注：该图基于自然资源部标准地图服务网站下载的审图号为GS（2021）××××号的标准地图制作，底图边界无修改。”

表：表的编排一般是内容和测试项目由左至右横读，数据依序竖排，应有自明性，引用的表必须注明来源。具体要求如下：

- 每一表应有简短确切的题名，连同表序置于表上居中。必要时，应将表中的符号、标记、代码及需说明的事项，以最简练的文字横排于表下作为表注。表题建议用中文及英文两种文字表达。
- 表内同一栏数字必须上下对齐。表内不应用“同上”、“同左”等类似词及“″”符号，一律填入具体数字或文字，表内“空白”代表无此项，“—”或“…”（因“—”可能与代表阴性反应相混）代表未发现，“0”该表实测结果为零。表内未测出值可以用“N.D.”表示。
- 表格尽量用“三线表”，避免出现竖线，避免使用过大的表格，确有必要时可采用卧排表，正确方位应为“顶左底右”，即表顶朝左，表底朝右。表格太大需要转页时，需要在续表表头上方注明“续表”，表头也应重复排出。
- 中文（宋体）英文（Times New Roman）表注为五号字，1.25倍行距。

（7）表达式

论文中的表达式需另行起，原则上应居中。若有两个以上的表达式，应从“1”开始的阿拉伯数字进行编号，并将编号置于括号内。编号采用右端对齐。表达式较多时可分章编号。

较长的表达式如必须转行，只能在+，-，×，÷，＜，＞等运算符之后转行，序号编于最后一行右顶格。

=== 参考文献
参考文献格式规范参照《信息与文献 参考文献著录规则》（GB/T
7714—2015），或可参照国际刊物通行的参考文献格式。各学科群分会可根据本学科的一般规范制定相应的参考文献格式。文后参考文献和参考文献在正文中的标注方式可采用“顺序编码制”或“著者—出版年制”。确定采用某种方法后，文后参考文献和参考文献在正文中的标注方式要对应。

文后参考文献按“顺序编码制”组织时，各篇文献应按正文部分首次引用时标注的序号依次列出；文后参考文献按“著者—出版年制”组织时，条目不排序号，先按语种分类排列，语种顺序是：中文、日文、西文、俄文、其他文种；然后按著者字序和出版年排列。中文和日文按第一著者的姓氏笔画排序，中文也可按汉语拼音字母顺序排列，西文和俄文按第一著者姓氏字母顺序排列。当一个著者有多篇文献并为第一著者时，该著者单独署名的文献排在前面（并按出版年份的先后排列），接着排该著者与其他人合写的文献。
文后参考文献加标题“参考文献”，并列入全文目录。凡正文里标注了参考文献的，其文献都必须列入文后参考文献。文后参考文献应集中著录于正文之后，不分章节著录。正文中未被引用但被阅读或具有补充信息的文献可集中列入附录中，其标题为“荐读书目”。

详细内容请参考《中国科学院大学研究生学位论文撰写规范指导意见》。

== 排版与印刷要求

以下仅摘录纸张与页面设置、书脊、印刷装订三项；封面、摘要、目录、正文、其他各项的字体字号等细则见《指导意见》原文三、（二）（四）～（七），本模板的正文样式已据此校准（对照见 `docs/CUSTOMIZE.md`）。

#bitable(
  table(
    align: center,
    columns: 2,
    stroke: none,
    table.hline(),
    [项目名称], [要求],
    table.hline(stroke: .5pt),
    [纸张], [A4（210mm×297mm），幅面白色],
    [页面设置], [上、下2.54cm，左、右3.17cm，页眉、页脚距页边界1.5cm],
    [封面], [采用国科大统一格式],
    [页眉], [宋体小五号居中，英文和阿拉伯数字用 Times New Roman 体],
    [页码], [Times New Roman 体小五号],
    table.hline(),
  ),
  caption-zh: [纸张要求和页面设置],
  caption-en: [Paper Requirements and Page Setup],
) <tbl:typo_and_print_require>

=== 印刷及装订要求
论文封面使用中国科学院大学统一的封面格式。学位论文用A4标准纸（210 mm×297
mm）打印、印刷或复印，按顺序装订成册。自中文摘要起双面印刷，之前部分单面印刷。中文摘要、英文摘要、目录、论文正文、参考文献、附录、致谢、作者简历及攻读学位期间发表的学术论文与其他相关学术成果等，均须由另页右页（奇数页）开始。论文必须用线装或热胶装订，不使用钉子装订。封面用纸一般为150克花纹纸（需保证论文封面印刷质量，字迹清晰、不脱落），博士学位论文封面颜色为红色，硕士学位论文封面颜色为蓝色。

=== 书脊
学位论文的书脊用黑体，英文和阿拉伯数字用 Times New Roman 体，字号一般为小四号，可根据论文厚度适当调整。上方写论文题目，中间写作者姓名，下方写“中国科学院大学”，距上下边界均为3cm左右。


// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
// bilingual-bibliography 已内置奇数页起始分页（见 utils/bilingual-bibliography.typ），
// 无需在此额外 pagebreak，否则会产生多余空白页。
#bilingual-bibliography(full: true)

// 附录
#show: appendix

= 附录

== 附录中的多行公式

附录中的多行公式使用 `aligned-equation` 函数，编号对齐到最后一行右侧：

#aligned-equation[$
  e^x & = sum_(n=0)^infinity x^n / n! \
      & = 1 + x + x^2/2 + x^3/6 + dots.c
$] <app-taylor>

由式 @eqt:app-taylor 可以得到自然指数函数的 Taylor 展开。

== 附录中的图表

附录中的图表与正文使用相同的 `bifigure`/`bitable`/`auto-table`/`continued-table` 函数，无需额外传参。模板会自动将附录图表题注中的量词由正文的「图/表」切换为「附图/附表」（英文 `Appendix Figure`/`Appendix Table`），并使编号在附录内从 1 重新计数（如附图1-1、附表1-1），符合《撰写规范》"附录的图表参考正文的编号方式，如附图1-1或附表1-1"的要求。引用方式与正文一致，仍使用类型前缀标签 `@fig:label`、`@tbl:label`。

=== 附录中的图与表

#bifigure(
  image("images/ucas-emblem.svg", width: 10%),
  caption-zh: [附录插图示例],
  caption-en: [Appendix Figure Example],
) <app-emblem>

如附图 @fig:app-emblem 所示，附录插图自动以"附图1-1"编号。

#bitable(
  table(
    columns: (auto, auto),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [项目], [说明],
    table.hline(stroke: .5pt),
    [前缀], [附图 / 附表],
    [编号], [附录内从 1 重新计数],
    table.hline(),
  ),
  caption-zh: [附录表格示例],
  caption-en: [Appendix Table Example],
) <app-summary>

如附表 @tbl:app-summary 所示，附录表格自动以"附表1-1"编号。

=== 附录中的续表

附录中的 `auto-table` 与 `continued-table` 同样会自动使用"附表"前缀。当附录表格数据较多需要跨页时，使用 `auto-table` 可自动在续页显示"续表"标记和表头；若希望精确控制续表位置，可先创建原表再用 `continued-table` 续接，其 `source` 参数须使用带前缀的标签 `<tbl:...>`。

// 行数须足够跨页（60 行约两页），否则演示不出续表表头与"（续表）"标记。
#{
  let cells = ()
  for i in range(1, 61) {
    cells.push([#i])
    cells.push([#("附录续表第" + str(i) + "项")])
  }
  auto-table(
    caption-zh: [附录自动续表示例],
    caption-en: [Appendix Auto-continued Table Example],
    columns: 2,
    align: center,
    stroke: none,
    header: (
      table.hline(),
      [序号],
      [说明],
      table.hline(stroke: .5pt),
    ),
    label: <app-auto>,
    ..cells,
    table.hline(),
  )
}

自动续表示例可通过附表 @tbl:app-auto 引用。

// 手动续表：source 须使用带前缀的标签 <tbl:...>
#continued-table(
  <tbl:app-summary>,
  align(center)[
    #table(
      columns: (auto, auto),
      align: center + horizon,
      stroke: none,
      table.hline(),
      [项目], [补充说明],
      table.hline(stroke: .5pt),
      [前缀], [由"表"切换为"附表"],
      [编号], [与原表一致，附表1-1],
      table.hline(),
    )
  ],
  note: [附录续表继承原表的"附表"前缀与编号。],
)

=== 无编号的展示性表格

附录中的对照表、说明性表格若无需编号、无需收录于图表目录，可直接使用原生 `table` 函数，并用 `#align(center)[#strong[...]]` 手动添加居中加粗标题。此类表格不参与图表编号，与上文 `bitable`（编号为附表1-1、收录于图表目录）形成互补：需要引用的表格用 `bitable`，仅作展示的表格用原生 `table`。

#degree-table()

// 致谢
#acknowledgement[
  首先感谢导师×××教授在选题、研究与论文撰写过程中给予的悉心指导，感谢课题组的同学们在实验与写作中给予的帮助，感谢家人在求学路上的理解与支持。

  本论文采用 modern-ucas-thesis 模板排版。该模板基于 #link("https://github.com/nju-lug/modern-nju-thesis")[modern-nju-thesis] 开发，版式参考 #link("https://github.com/mohuangrui/ucasthesis")[ucasthesis] LaTeX 模板；排版引擎为 #link("https://typst.app")[Typst]，中文伪加粗、参考文献样式与代码格式化分别由 cuti、GB/T 7714—2015 CSL 与 typstyle 提供。谨向上述开源项目及标准的贡献者致谢。
]


// 后置部分小节标题：统一段前段后间距；各节用 enum 自动编号，增删条目
// 序号自动重排。全角 ×× 为占位符请替换；整节不需要（如无专利）可整段删除。
#let bm-sec(title) = block(above: 2em, below: 1em)[#strong[#title]]
#backmatter[
  #set enum(numbering: "(1)")
  #bm-sec[作者简历：]

  ××××年××月——××××年××月，在××大学××院（系）获得学士学位。

  ××××年××月——××××年××月，在××大学××院（系）获得硕士学位。

  ××××年××月——××××年××月，在中国科学院大学 中国科学院××研究所 攻读博士/硕士学位。

  工作经历：（如无可删除本行）××××年××月——××××年××月，在××单位任××职务。

  #bm-sec[已发表（或正式接受）的学术论文：]

  + 张三，李四，王五. 基于示例数据的演示性研究方法[J]. 演示学报，2024, 12(3): 101-112.

  + San Zhang, Si Li, Wu Wang. A Fictitious Framework for Demonstration Purposes[C]//Proceedings of the International Conference on Illustrative Examples. Beijing: 示例出版社， 2023: 55-63.

  #bm-sec[申请或已获得的专利：]

  + 张三，李四. 一种用于演示的示例装置：CN202410000001.1[P]. 2024-01-01.

  + 王五. 一种示例性演示方法：CN202430000002.2[P]. 2024-02-02.

  #bm-sec[参加的研究项目及获奖情况：]

  + 示例科学基金重点项目"虚构场景下的演示方法研究"（批准号：00000000），2024—2026，主持.

  + 某某单位演示奖，2024.
]
