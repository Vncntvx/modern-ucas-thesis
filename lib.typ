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
#import "utils/style.typ": get-fonts, 字体组, 字号

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
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
      )
    },
    mainmatter: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        mainmatter(
          twoside: twoside,
          display-header: true,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
          ref-supplements: ref-supplements,
        )
      } else {
        mainmatter(
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
          ref-supplements: ref-supplements,
        )
      }
    },
    appendix: (..args) => {
      appendix(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
        ref-supplements: ref-supplements,
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
          info: info + args.named().at("info", default: (:)),
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
      )
    },
    // 符号表页
    notation: (..args) => {
      notation(
        twoside: twoside,
        fontset: fontset,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
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
      )
    },
    // 致谢页
    acknowledgement: (..args) => {
      acknowledgement(
        anonymous: anonymous,
        twoside: twoside,
        fontset: fontset,
        date: info.at("submit-date", default: none),
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
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
