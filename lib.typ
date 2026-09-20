// 中国科学院大学学位论文模板 modern-ucas-thesis
// Author: https://github.com/Vncntvx
// Repo: https://github.com/Vncntvx/modern-ucas-thesis

#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/fonts-display-page.typ": fonts-display-page
#import "pages/bachelor-cover.typ": bachelor-cover
#import "pages/master-cover.typ": master-cover
#import "pages/bachelor-decl-page.typ": bachelor-decl-page
#import "pages/master-decl-page.typ": master-decl-page
#import "pages/bachelor-abstract.typ": bachelor-abstract
#import "pages/master-abstract.typ": master-abstract
#import "pages/bachelor-abstract-en.typ": bachelor-abstract-en
#import "pages/master-abstract-en.typ": master-abstract-en
#import "pages/outline-page.typ": outline-page
#import "pages/list-of-figures-and-tables.typ": list-of-figures-and-tables
#import "pages/notation.typ": notation
#import "pages/acknowledgement.typ": acknowledgement
#import "pages/backmatter.typ": backmatter
#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-figure.typ": bifigure, bitable
#import "utils/bilingual-figured.typ": show-equation, show-figure
#import "utils/continued-table.typ": auto-table, continued-table
#import "utils/aligned-equation.typ": aligned-equation
#import "utils/theorem.typ": (
  assertion, axiom, conjecture, corollary, definition, example, lemma, proof,
  proposition, remark, theorem,
)
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/supervisor.typ": (
  normalize-supervisors, supervisor-en-line, supervisor-line,
)
#import "utils/datetime-display.typ": datetime-display, datetime-display-compact
#import "utils/style.typ": get-fonts, 字体组, 字号
#import "pages/proposal.typ": (
  default-proposal-cfg, proposal-cover, proposal-doc, proposal-mainmatter,
  proposal-notice, proposal-numbering, proposal-outline-page,
  proposal-page-footer,
)

// 借助函数闭包特性：`documentclass` 集中进行全局信息配置，返回携带该配置的
// 布局（layouts）与页面（pages）函数字典。

#let documentclass(
  doctype: "doctor", // "bachelor" | "master" | "doctor"，文档类型，默认为博士生 doctor
  degree: "academic", // "academic" | "professional"，学位类型，默认为学术型 academic
  twoside: false, // 双面模式，会加入空白页，便于打印
  anonymous: false, // 盲审模式
  bibliography: none, // 参考文献函数
  // 交叉引用量词自动补全（图/表/式/定理类）：默认 none（关闭），由作者在正文手写
  // 量词（如「图 1-1」「式 (1-2)」「定理 2-1」，便于连续引用与自定义措辞）；设为 auto
  // 开启：图/表随双语题注（图/表/附图/附表），公式为「式」，定理类随种类
  // （定理/引理/定义/例…，标签前缀见 utils/theorem.typ 的 _thm-refspec）；
  // 也可传字典按引用前缀自定义，如 (eqt: [公式])，定理类按 thm/def/ex
  // 三组设键，未提供的类型回落 auto 行为。
  ref-supplements: none,
  // 字体配置说明:
  // - fontset参数用于选择预定义的字体组（windows、mac、fandol或adobe）
  // - fonts参数用于覆盖或补充fontset中的字体设置，提供更精细的字体控制
  // - 对大多数用户而言，只需设置fontset即可；对有特殊需求的用户，可使用fonts参数自定义
  fontset: "mac", // "windows" | "mac" | "fandol" | "adobe"，选择预定义的字体组
  fonts: (:), // 用于覆盖或补充fontset中的字体，可选择性覆盖
  info: (:),
) = {
  // 早失败：ref-supplements 仅接受 none / auto / 字典，避免布尔、字符串等
  // 误传在深层 show-figure 的 `.at` 处才崩溃（且公式与图表两处行为不一致）。
  assert(
    ref-supplements == none
      or ref-supplements == auto
      or type(ref-supplements) == dictionary,
    message: "ref-supplements 须为 none、auto 或字典（如 (eqt: [公式])）",
  )
  // 根据 fontset 参数选择对应的字体组
  // 将用户自定义的fonts与预定义字体组合并，用户定义的字体会覆盖预定义字体
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
      title-en: "UCAS Thesis Template for Typst",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      author-en: "Zhang San",
      department: "某研究所",
      department-en: "Institute of XXX",
      major: "xx 专业",
      major-en: "xx major",
      category: "学科门类或专业学位类别",
      category-en: "XX category",
      // 导师信息：字典列表 (name:, title:, affiliation:)，多导师第一导师在前。
      supervisors: (
        (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
      ),
      supervisors-en: (
        (
          name: "Si Li",
          title: "Professor",
          affiliation: "Institute of XXX, Chinese Academy of Sciences",
        ),
      ),
      submit-date: datetime.today(),
      // 密级（规范一·（一）·1）：涉密/延迟公开论文标注，公开论文不标注。
      secret-level: "公开",
      // 涉密/延迟公开论文的保密期限（如 "10年"），封面渲染为"密级：秘密★10年"。
      secret-year: none,
      degree: auto,
      degree-en: auto,
    )
      + info
  )

  return (
    // 将传入参数再导出
    doctype: doctype,
    degree: degree,
    twoside: twoside,
    anonymous: anonymous,
    fonts: fonts,
    info: info,
    // 页面布局
    doc: (..args) => {
      doc(
        ..args,
        fontset: fontset,
        // doctype 决定本科专属样式（圈码脚注、合成上标）；研究生保持既有输出。
        doctype: doctype,
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    mainmatter: (..args) => {
      // master/doctor 与 bachelor 走同一分支：mainmatter 的 display-header 默认即 true，
      // 且 ..args 晚于显式命名参数生效，显式传 display-header: true 不产生任何差异。
      mainmatter(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        ref-supplements: ref-supplements,
        doctype: doctype,
      )
    },
    appendix: (..args) => {
      appendix(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        ref-supplements: ref-supplements,
        doctype: doctype,
      )
    },
    // 字体展示页
    fonts-display-page: (..args) => {
      fonts-display-page(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 封面页，通过 type 分发到不同函数
    cover: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-cover(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else {
        bachelor-cover(
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 声明页，通过 type 分发到不同函数
    decl-page: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else {
        bachelor-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      }
    },
    // 中文摘要页，通过 type 分发到不同函数
    abstract: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-abstract(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else {
        bachelor-abstract(
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 英文摘要页，通过 type 分发到不同函数
    abstract-en: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-abstract-en(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else {
        bachelor-abstract-en(
          anonymous: anonymous,
          twoside: twoside,
          fontset: fontset,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 目录页
    outline-page: (..args) => {
      outline-page(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 图表目录页
    list-of-figures-and-tables: (..args) => {
      list-of-figures-and-tables(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 符号表页
    notation: (..args) => {
      notation(
        twoside: twoside,
        fontset: fontset,
        ..args,
        // 本科按规范一·（五）用词"符号说明"；研究生保持既有标题"符号列表"。
        title: if doctype == "bachelor" { "符号说明" } else { "符号列表" },
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(
        bibliography: bibliography,
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 致谢页
    acknowledgement: (..args) => {
      acknowledgement(
        anonymous: anonymous,
        twoside: twoside,
        fontset: fontset,
        date: info.at("submit-date", default: none),
        // 日期写法与对应封面一致：本科用紧凑式"20XX年X月"，研究生用"20XX 年 X 月"。
        date-display: if doctype == "bachelor" {
          datetime-display-compact
        } else {
          datetime-display
        },
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 个人信息页
    backmatter: (..args) => {
      backmatter(
        anonymous: anonymous,
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        doctype: doctype,
      )
    },
    // 双语图表函数
    bifigure: bifigure,
    bitable: bitable,
    // 工具函数
    continued-table: continued-table,
    auto-table: auto-table,
    aligned-equation: aligned-equation,
    // 定理类数学环境（对齐 amsthm，随章编号）
    axiom: axiom,
    theorem: theorem,
    lemma: lemma,
    corollary: corollary,
    assertion: assertion,
    proposition: proposition,
    conjecture: conjecture,
    definition: definition,
    example: example,
    remark: remark,
    proof: proof,
  )
}

// 开题报告

#let proposalclass(
  doctype: "master", // "bachelor" | "master"，开题类型；本科生版式暂与研究生一致
  fontset: "mac", // "windows" | "mac" | "fandol" | "adobe"
  fonts: (:),
  info: (:),
  bibliography: none, // 参考文献函数，如 bibliography.with("ref.bib")
  // 版面微调（覆盖 default-proposal-cfg 中的同名项）
  cfg: (:),
) = {
  fonts = get-fonts(fontset) + fonts
  cfg = default-proposal-cfg + cfg
  info = (
    (
      // 题目：字符串可用 \n 手动分行，例如 "上半段\\n下半段"
      title: "在此填写开题报告题目",
      author: "张三",
      student-id: "1234567890",
      // 指导教师（必须填写，不可为空；两种数据至少填一种）
      //   supervisors-full : 整行，如 "李四教授" / "李四教授 王五研究员"
      //   supervisors-split: 分栏，(name: "李四", title: "教授")
      // 形式控制 supervisor-form：
      //   auto    — 按已填形式自动识别；两种都填 → 展示整行并预警（不报错）
      //   "full"  — 只允许填整行，否则报错
      //   "split" — 只允许填分栏，否则报错
      supervisors-full: "李四教授",
      supervisors-split: none,
      supervisor-form: auto,
      // 学术型：哲学硕士 / 理学硕士 / 工学硕士 …；专业型：工程硕士 / MBA …
      degree-category: "工学硕士",
      major: "计算机科学与技术",
      research-direction: "智能信息处理",
      department: "中国科学院××研究所",
      // 可写 datetime 或字符串；字符串原样输出
      submit-date: datetime.today(),
    )
      + info
  )

  return (
    doctype: doctype,
    fonts: fonts,
    info: info,
    cfg: cfg,
    // 基础页面设置（A4、页边距、默认字体）
    doc: (..args) => {
      proposal-doc(
        fonts: fonts,
        cfg: cfg,
        ..args,
      )
    },
    // 封面
    cover: (..args) => {
      proposal-cover(
        doctype: doctype,
        fonts: fonts,
        info: info + args.named().at("info", default: (:)),
        cfg: cfg,
      )
    },
    // 填表说明
    notice: (..args) => {
      proposal-notice(
        fonts: fonts,
        cfg: cfg,
        ..args,
      )
    },
    // 报告提纲（自正文标题自动收集）
    outline-page: (..args) => {
      proposal-outline-page(
        fonts: fonts,
        cfg: cfg,
        ..args,
      )
    },
    // 正文布局：标题 1. / 1.1. / 1.1.2，正文首行缩进
    mainmatter: (..args) => {
      proposal-mainmatter(
        fonts: fonts,
        info: info + args.named().at("info", default: (:)),
        cfg: cfg,
        ..args,
      )
    },
    // 参考文献（复用学位论文双语引擎；page-decoration: none 由开题自管页脚）
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(
        bibliography: bibliography,
        fontset: fontset,
        fonts: fonts,
        info: info + args.named().at("info", default: (:)),
        page-decoration: none,
        ..args,
      )
    },
    // 页脚与标题编号（便于自定义页面复用）
    page-footer: () => proposal-page-footer(fonts: fonts),
    numbering: proposal-numbering,
    // 正文常用工具
    bifigure: bifigure,
    bitable: bitable,
    continued-table: continued-table,
    auto-table: auto-table,
    aligned-equation: aligned-equation,
  )
}

