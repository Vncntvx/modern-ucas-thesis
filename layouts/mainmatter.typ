#import "../utils/bilingual-figured.typ"
#import "../utils/custom-figure.typ": thesis-bilingual-caption-style
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": mainmatter-foreground
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/citation-range-hyphen.typ": citation-range-hyphen
#import "../utils/unpairs.typ": unpairs
#import "../utils/theorem.typ": reset-theorem-counters, show-theorem-ref

// 标题邻接表（文档序预计算）。show 规则内 query(selector.X.after().before())
// 不可靠（恒为空），故在文档流中一次性算好，经 state 供 show 规则按下标读取。
#let _heading-adj = state("modern-ucas-heading-adj", ())

#let mainmatter(
  // documentclass 传入参数
  twoside: false,
  info: (:),
  fonts: (:),
  fontset: "mac",
  // 交叉引用量词：none（默认）关闭，量词由作者手写（便于连续引用与自定义
  // 措辞）；auto 随题注（图/表/附图/附表），公式为「式」，定理类随种类
  // （定理/引理/定义/例…）；字典按引用前缀自定义（fig/tbl/eqt，定理类按
  // thm/def/ex 三组，缺省项回落）。经 lib.typ 传入。
  ref-supplements: none,
  // 其他参数
  // 正文行距：Typst leading 是行盒之间的额外间隙，
  // 取 行距.正文（1.1em）使基线间距约 21.6pt（对齐 LaTeX 参考实现），勿写 1.25em。
  leading: 行距.正文,
  // 正文段前段后 0 磅：Typst 的段间距不含行距（只计额外间隙），
  // Word"0 磅"语义 = 段间基线距与行内一致，故取与 leading 等值，勿写 0pt
  //（0pt 会使段间基线距小于行内，段落粘连偏紧）。
  spacing: 行距.正文,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  // 章节编号格式
  // 序号与题名间"空一个汉字符"（=1em=1 全角汉字宽）。
  // 用全角空格 U+3000（IDEOGRAPHIC SPACE）实现，其在 CJK 字体下宽度恒为 1em，
  // 均精确等于 1em。半角空格 U+0020 仅约 0.25em，不满足规范。
  numbering: custom-numbering.with(
    first-level: "第1章\u{3000}",
    depth: 4,
    "1.1\u{3000}",
  ),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.四号, 字号.小四, 字号.小四, 字号.小四),
  heading-weight: ("bold", "regular", "regular", "regular"),
  // 标题段前段后间距（规范值）
  // 一级标题：段前24pt，段后18pt
  // 二级标题：段前24pt，段后6pt
  // 三级标题：段前12pt，段后6pt
  // 四级标题：段前12pt，段后6pt
  heading-above: (24pt, 24pt, 12pt, 12pt),
  heading-below: (18pt, 6pt, 6pt, 6pt),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  display-header: true,
  // 页眉分隔线
  stroke-width: 0.8pt,
  reset-footnote: true,
  // caption 的 separator
  separator: "  ",
  // caption 样式
  caption-style: strong,
  caption-size: 字号.五号,
  ..args,
  it,
) = {
  // 0.  默认参数（须在换页前解析：foreground 工厂需要 fonts/info）
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
    )
      + info
  )
  fonts = get-fonts(fontset) + fonts

  // 1.  前言 → 正文 的编号域切换
  //
  // 页码域规则：正文前（摘要…）连续罗马数字；正文起阿拉伯数字。
  // 换页产生的填充页必须仍属于「上一编号域」：若先 set 正文（阿拉伯 +
  // mainmatter-foreground）再 pagebreak(to:"odd")，填充页会用正文样式把
  // 前言物理计数渲染成 10、11…，与前言罗马页码断裂。
  //
  // 正确顺序（与 preface 同一原则）：
  //   pagebreak（填充页继承前言罗马页码）→ set 正文样式 → 计数器重置为 1。
  // 正文章内的填充页（章标题 to 前的另页）发生在 set 之后，仍是阿拉伯，不受影响。
  pagebreak(weak: true, to: if twoside { "odd" })
  // footer: none 必需：set page(numbering:) 会自动在页脚渲染一个环境样式的
  // 页码（auto footer），与下方 foreground 定制的页码重影，必须显式关闭。
  set page(
    numbering: "1",
    footer: none,
    foreground: mainmatter-foreground(
      twoside: twoside,
      info: info,
      fonts: fonts,
      display-header: display-header,
      stroke-width: stroke-width,
      reset-footnote: reset-footnote,
    ),
  )

  // 2.  参数处理
  // 2.1 文字参数
  // 文字边缘设置，用于控制行高计算基准
  // "cap-height": 大写字母的大致高度
  // "baseline": 字母的基线
  let base-text-args = (top-edge: "cap-height", bottom-edge: "baseline")
  if (text-args == auto) {
    text-args = (font: fonts.宋体, size: 字号.小四) + base-text-args
  } else {
    // 合并用户自定义参数与边缘设置
    text-args = base-text-args + text-args
  }

  // 2.2 标题字体默认值
  if (heading-font == auto) {
    heading-font = (fonts.黑体,)
  }
  // 2.3 处理 heading- 开头的其他参数
  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 3.  辅助函数
  let array-at(arr, pos) = {
    // 如果值是数组，根据位置获取；如果是标量，直接使用该值
    if type(arr) == array {
      arr.at(calc.min(pos, arr.len()) - 1)
    } else {
      arr
    }
  }

  // 4.  设置基本样式
  // 4.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    spacing: spacing,
    justify: justify,
    first-line-indent: first-line-indent,
  )
  show raw: set text(font: fonts.等宽)

  // 4.2 脚注样式：五号字；脚注用单倍行距（LaTeX 脚注单倍，不随正文行距）。
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  show footnote.entry: set par(leading: 行距.单倍)

  // 4.3 设置 figure 的编号（ref-supplement 透传全局配置；none 时保留原字段
  // 为裸编号，auto/字典时自动补量词，见 bilingual-figured）。
  show heading: bilingual-figured.reset-counters
  show figure: bilingual-figured.show-figure.with(
    ref-supplement: ref-supplements,
  )

  let bilingual-caption-style = thesis-bilingual-caption-style(fonts)
  show figure: bilingual-figured.show-bilingual.with(
    figure_style: bilingual-caption-style,
    table_style: bilingual-caption-style,
  )

  // 定理类引用（`thm:` 等九前缀，见 utils/theorem.typ 的 _thm-refspec）。
  // show ref 链可叠加：citation-range-hyphen 只认文献引用，本规则只认
  // 定理前缀，其余都原样返回，故顺序无关。
  show ref: show-theorem-ref.with(ref-supplement: ref-supplements)

  // 4.4 设置 equation 的编号和假段落首行缩进
  // 公式编号对齐到最后一行右侧（UCAS 规范：序号编于最后一行右顶格）
  set math.equation(number-align: bottom + end)
  // 引用量词（ref-supplements）：默认 none，量词由作者手写；开启时公式引用
  // 经 supplement 自动带前缀（supplement 仅加在 @eqt: 引用的编号之前，
  // 不影响公式自身的编号显示）。解析集中在 bilingual-figured，避免与附录重复。
  set math.equation(
    supplement: bilingual-figured.resolve-equation-supplement(ref-supplements),
  )
  // 公式编号字体：不覆盖。勿对 math.equation 做 set text 换字体（如统一编号
  // 字体为宋体）：set 规则作用于整个公式，会迫使公式符号（φ、∫、⌊⌋等）向
  // 非数学字体回退，导致缺字形 tofu；且 Typst 0.15 无独立设置编号字号的 API。
  // 编号内容为纯阿拉伯数字与括号，按规范"英文和阿拉伯数字用 Times New Roman
  // 体"，默认数学字体（Times 风格衬线）即合规。
  // 字号继承正文小四（规范五号 10.5pt，Typst 固有限制，见 docs/CUSTOMIZE.md）。
  show math.equation.where(block: true): bilingual-figured.show-equation

  // 4.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: fonts.宋体, size: 字号.五号)

  // 4.6 顺序编码制参考文献引用：连续序号分隔符修正
  //     gb-7714-2015-numeric CSL 默认用 en dash"–"连接连续序号，UCAS 规范要求用 hyphen"-"。
  //     仅对参考文献引用（it.element == none）生效，图表/公式/标题引用原样返回。
  //     序号上标与多篇合并（[1,2]/[1-4]）由 CSL 默认提供，需用 @a@b 紧邻书写触发合并。
  show ref: citation-range-hyphen

  // 4.7 优化列表显示
  // 术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: (amount: 0pt, all: true))

  // 5.  处理标题
  // 5.1 设置标题的 Numbering
  set heading(numbering: numbering)

  // 5.2 设置标题的段前段后间距
  //
  // 语义（Typst 官方 block/par）：`block(above/below)` 与相邻块按 max 折叠，
  // 且优先于 `par.spacing`；显式 `v()` 与块间距相加。正文 `spacing = 行距.正文`
  // （≈13.2pt@小四）对应 Word「段前段后 0 磅」。
  //
  // - L1：5.4 显式 v(24pt)，换页后保留；块上间距取 0。
  // - 非连续标题：L2 段前 24pt；L3/L4 段前 12pt + 半个 leading。
  // - 连续标题（两标题之间无段落/列表/图表等）：上一标题段后 = 规范值 + 6pt，
  //   下一标题段前 = 6pt，折叠后约 12pt，既紧凑又不粘连。
  //   邻接关系在下方 context 块按文档序预计算；show 内不用 after/before query
  //   （实测恒返回空），也不用 position（误判会导致叠字）。
  context {
    let heads = query(heading)
    let flags = ()
    for i in range(heads.len()) {
      let h = heads.at(i)
      let has-mid(a, b) = {
        (
          query(
            selector(par)
              .or(selector(list))
              .or(selector(enum))
              .or(selector(figure))
              .or(selector(math.equation))
              .or(selector(raw))
              .after(a)
              .before(b),
          ).len()
            > 0
        )
      }
      flags.push((
        // 与上一标题之间是否有正文
        cluster-prev: if i == 0 {
          false
        } else {
          not has-mid(heads.at(i - 1).location(), h.location())
        },
        // 与下一标题之间是否有正文
        cluster-next: if i + 1 >= heads.len() {
          false
        } else {
          not has-mid(h.location(), heads.at(i + 1).location())
        },
      ))
    }
    _heading-adj.update(flags)
  }

  show heading: it => context {
    let body-leading-abs = 13.2pt
    let half-body-leading = 6.6pt

    let heads = query(heading)
    let idx = heads.position(h => h.location() == it.location())
    let flags = if idx == none {
      (cluster-prev: false, cluster-next: false)
    } else {
      _heading-adj
        .get()
        .at(idx, default: (
          cluster-prev: false,
          cluster-next: false,
        ))
    }

    let spec-above = array-at(heading-above, it.level)
    let spec-below = array-at(heading-below, it.level)
    // 聚簇时保留的最小空气，避免标题粘成一团
    let cluster-gap = 6pt

    let actual-above = if it.level == 1 {
      0pt
    } else if flags.cluster-prev {
      cluster-gap
    } else if it.level >= 3 {
      spec-above + half-body-leading
    } else {
      spec-above
    }
    let actual-below = if flags.cluster-next {
      spec-below + cluster-gap
    } else {
      spec-below + body-leading-abs
    }
    set block(
      above: actual-above,
      below: actual-below,
    )
    it
  }

  // 5.3 设置标题的字体、字号、行距等样式
  show heading: it => {
    // 标题使用单倍行距：取 行距.单倍（0.5em），勿写 1em
    //（1em 额外间隙远超单倍）。
    set par(leading: 行距.单倍, spacing: 行距.单倍)
    // 设置标题字体、字号、加粗等样式
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(
        heading-text-args-lists.map(
          pair => (pair.at(0), array-at(pair.at(1), it.level)),
        ),
      ),
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )
    it
  }

  // 5.4 标题居中与自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        pagebreak(weak: true)
      }
    }
    // L1 段前用显式 v 落实规范值（换页符后保留，见 5.2 注释）。
    // L2+ 段前已由 5.2 的块上间距落实（max 折叠 + 页顶裁剪），此处不再发射 v
    // （v 会与块段后相加，破坏折叠）。
    if it.level == 1 {
      v(array-at(heading-above, it.level))
      // 定理类环境计数器随章清零（定理 1-1、定理 2-1 …）
      reset-theorem-counters()
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 6.  正文首页页码重置为 1（前言罗马序号在此截断，正文另起阿拉伯序）。
  //    填充页样式：正文前的填充页继承前言罗马页码；章内填充页用上面 set 的正文样式。
  counter(page).update(1)

  it
}
