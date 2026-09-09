#import "../utils/bilingual-figured.typ"
#import "../utils/page-foreground.typ": mainmatter-foreground
#import "../utils/style.typ": get-fonts, 字号
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/citation-range-hyphen.typ": citation-range-hyphen
#import "../utils/theorem.typ": show-theorem-ref

// 附录图表"参考正文的编号方式，如附图1-1或附表1-1"，
// 即附录中图/表的前缀须为"附图/附表"（英文 Appendix Figure / Appendix Table），
// 与正文的"图/表"区分。supplement 写在双语 caption 的 metadata 中、绕开
// Typst 原生 supplement 字段，故须在 show-figure 重建 figure 时改写 metadata。
// 此函数按 kind 自动选择附图/附表前缀，再交由通用 show-figure 重建。
#let _appendix-show-figure(
  numbering: "1-1",
  supplement-zh-figure: [附图],
  supplement-en-figure: [Appendix Figure],
  supplement-zh-table: [附表],
  supplement-en-table: [Appendix Table],
  ref-supplement: none,
  it,
) = {
  // 原生 `kind: table`（函数，非字符串）同样判为表，见 bilingual-figured
  // 的 _figure-ref-key；仅用 is-kind 会漏掉该情形。
  let is-table = (
    it.kind == table
      or bilingual-figured.is-kind(it.kind, "bitable")
      or bilingual-figured.is-kind(
        it.kind,
        "table",
      )
  )
  bilingual-figured.show-figure(
    it,
    numbering: numbering,
    supplement-zh: if is-table { supplement-zh-table } else {
      supplement-zh-figure
    },
    supplement-en: if is-table { supplement-en-table } else {
      supplement-en-figure
    },
    ref-supplement: ref-supplement,
  )
}

// 附录布局。
//
// 设计说明：本函数只声明附录与正文的*差异项*（编号前缀、无编号一级标题、
// 图表目录收录、计数器重置、页面与页眉页脚）。正文字体/行距/标题字号字形/
// 图表标题/脚注等基础样式不重复设置——标准组装顺序下附录区位于
// `#show: mainmatter` 的作用域之内（show 规则嵌套），自动继承 mainmatter
// 的全部 set/show 规则，与 LaTeX 参考实现中附录沿用文档类全局样式一致。
// 在此重复设置 set text/par/show heading 会与外层规则叠加（如标题 v 间距
// 翻倍），故刻意保持精简。
#let appendix(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 交叉引用量词：none（默认）关闭，量词由作者手写；auto 随题注（附图/附表），
  // 公式为「式」，定理类随种类（定理/引理/定义/例…）；字典按引用前缀自定义
  // （fig/tbl/eqt，定理类按 thm/def/ex 三组，缺省项回落）。经 lib.typ 传入。
  ref-supplements: none,
  numbering: custom-numbering.with(first-level: "", depth: 4, "1.1\u{3000}"),
  // figure 编号（附录图表前缀为"附图/附表"，编号 1-1）
  show-figure: _appendix-show-figure.with(numbering: "1-1"),
  // equation 编号（(1-1)）
  show-equation: bilingual-figured.show-equation.with(numbering: "(1-1)"),
  // 重置计数：附录作为独立编号单元，图表/公式编号从 1 开始（附图1-1、附表1-1），
  // 而非继承正文章号（否则会显示附图4-1）。reset-counter 同时重置 heading 计数器，
  // 不影响附录标题显示（first-level 为空）及后续致谢/简历（同样无章号）。
  reset-counter: true,
  it,
) = {
  // 附录须由另页右页（奇数页）开始（双面印刷时）。
  // 起始页面样式：先设置页眉页脚（page.foreground）再换页，使双面模式下
  // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
  // 奇数页章名，页码按双面左右分置）。全静态实现，无运行时判断；info 由
  // documentclass 传入，供偶数页显示论文题目。
  fonts = get-fonts(fontset) + fonts
  set page(
    numbering: "1",
    footer: none,
    foreground: mainmatter-foreground(
      twoside: twoside,
      info: info,
      fonts: fonts,
    ),
  )
  pagebreak(weak: true, to: if twoside { "odd" })
  set heading(numbering: numbering)
  // 标记附录模式：bifigure/bitable 经 _appendix-show-figure 改写前缀为"附图/附表"，
  // auto-table 等通过 in-appendix() 读取此标记自行解析 supplement。
  bilingual-figured.enter-appendix-mode()
  // UCAS 规范：附录在目录中只列一级标题（与参考文献/致谢等"其他"项一致），
  // 故将附录二、三、四级标题排除出目录。outlined: false 仅影响目录收录，
  // 不影响编号显示（附录子节仍按 1.1 / 1.1.1 编号）。
  show heading.where(level: 2): set heading(outlined: false)
  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 4): set heading(outlined: false)
  // 公式编号对齐到最后一行右侧（UCAS 规范：序号编于最后一行右顶格）
  set math.equation(number-align: bottom + end)
  // 引用量词集中解析见 bilingual-figured（与正文 mainmatter 同口径）。
  set math.equation(
    supplement: bilingual-figured.resolve-equation-supplement(ref-supplements),
  )
  // 公式编号字体：不覆盖（与正文 mainmatter 一致；set text 会破坏数学字形，
  // 见 mainmatter 同名注释）。
  if reset-counter {
    counter(heading).update(0)
  }
  // 设置 figure 的编号（ref-supplement 透传全局配置；none 时保留原字段
  // 为裸编号，与正文 mainmatter 一致，无需按 none/non-none 分支）。
  show figure: show-figure.with(ref-supplement: ref-supplements)
  // 定理类引用（`thm:` 等九前缀，见 utils/theorem.typ；与正文规则一致，
  // 附录中定理仍称定理、不改附表前缀）。
  show ref: show-theorem-ref.with(ref-supplement: ref-supplements)
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  // 顺序编码制参考文献引用：连续序号分隔符修正（与正文 mainmatter 一致）
  show ref: citation-range-hyphen
  it
}
