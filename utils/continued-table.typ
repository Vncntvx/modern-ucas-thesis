#import "bilingual-figured.typ"
#import "style.typ": 字号, 行距

#let _typst-numbering = numbering

#let continuation-style(
  separator: h(1em),
  caption_align: center,
  // 1.25 倍行距：Typst leading 是行盒之间的额外间隙，取 行距.正文，勿写 1.25em。
  caption_par: (leading: 行距.正文),
  note_par: auto,
  zh_text: (size: 字号.五号, weight: "bold"),
  en_text: (size: 字号.五号, weight: "bold"),
  note_text: (size: 字号.五号),
  note_prefix: [*注：* ],
  note_align: left,
  // 块外间距：取规范值，但中英标题之间需保留一行行距（与 custom-figure
  // 同口径）。Typst leading 只在段落内部生效，两个单行 block 之间基线距
  // 不含 leading，其实测见 docs/CUSTOMIZE.md，故英文题段前取一个 leading。
  // 仅 _render-caption（手动续表）使用 zh_block/en_block；
  // _render-caption-outside 与续表 header 行用显式 caption_gap 分隔。
  zh_block: (above: 6pt, below: 0pt),
  en_block: (above: 行距.正文, below: 12pt),
  note_block: (above: 6pt, below: 0pt, inset: (left: 2em)),
  continued_mark_zh: [（续表）],
  continued_mark_en: [(continued)],
  // 续表表头中英文标题间距：同上，取一个 leading 使中英题基线距约 1.25×字号。
  caption_gap: 行距.正文,
  // 表题与表体间距：规范未定量，取 8pt（与 LaTeX 模板 caption skip 一致）。
  auto_header_gap: 8pt,
  table_align: center,
  cell_align: center,
  // 单元格内边距：对齐常见 LaTeX 三线表观感（上下约 4pt、左右 6pt），
  // 过紧会贴线，过松会把多列表挤出折行。
  cell_inset: (x: 6pt, y: 4pt),
  continued_block: (above: 1.25em, below: 1em),
) = (
  separator: separator,
  caption_align: caption_align,
  caption_par: caption_par,
  note_par: note_par,
  zh_text: zh_text,
  en_text: en_text,
  note_text: note_text,
  note_prefix: note_prefix,
  note_align: note_align,
  zh_block: zh_block,
  en_block: en_block,
  note_block: note_block,
  continued_mark_zh: continued_mark_zh,
  continued_mark_en: continued_mark_en,
  caption_gap: caption_gap,
  auto_header_gap: auto_header_gap,
  table_align: table_align,
  cell_align: cell_align,
  cell_inset: cell_inset,
  continued_block: continued_block,
)

#let _default-continuation-style = continuation-style()

#let _render-caption(
  number,
  caption_zh,
  caption_en,
  supplement_zh,
  supplement_en,
  style,
  continued: false,
) = [
  #set align(style.caption_align)
  #if style.caption_par != none and style.caption_par != (:) {
    set par(..style.caption_par)
  }
  #set text(..style.zh_text)
  #block(..style.zh_block)[
    #supplement_zh #number #style.separator #caption_zh
    #if continued { [#style.continued_mark_zh] }
  ]
  #if caption_en != none {
    set text(..style.en_text)
    block(..style.en_block)[
      #supplement_en #number #style.separator #caption_en
      #if continued { [#h(0.4em) #style.continued_mark_en] }
    ]
  }
]

// 表外题注（auto-table 首页）：规范中文段前 6、段后 0；英文段前 0、段后 12；
// 中英题之间用显式 v(行距.正文) 保证视觉间距（勿依赖 block above/below 折叠）。
// 只在首页渲染，恒不带续表标记。
#let _render-caption-outside(
  number,
  caption_zh,
  caption_en,
  supplement_zh,
  supplement_en,
  style,
) = [
  #set align(style.caption_align)
  #if style.caption_par != none and style.caption_par != (:) {
    set par(..style.caption_par)
  }
  #set text(..style.zh_text)
  #block(above: 6pt, below: 0pt)[
    #supplement_zh #number #style.separator #caption_zh
  ]
  #if caption_en != none {
    v(style.caption_gap)
    set text(..style.en_text)
    block(above: 0pt, below: 12pt)[
      #supplement_en #number #style.separator #caption_en
    ]
  }
]

#let _render-note(note, style) = if note == none {
  []
} else {
  let note-par = if style.note_par == auto {
    style.caption_par
  } else {
    style.note_par
  }
  [
    #set align(style.note_align)
    #if note-par != none and note-par != (:) {
      set par(..note-par)
    }
    #set text(..style.note_text)
    // 注续行缩进：grid 两列分置"注："前缀与注释正文，续行几何对齐至前缀之后。
    // 与 bilingual-figured._render-bilingual-note 同构，详见该处说明。
    #block(..style.note_block)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0pt,
        align: (left, left),
        style.note_prefix, note,
      )
    ]
  ]
}

// 编号数字序列解析沿用 bilingual-figured._prepare-heading-numbers 单点实现。
#let _prepare-heading-prefix = bilingual-figured._prepare-heading-numbers

#let _table-index-at(loc, kind: "bitable") = {
  let prefixed-index = counter(
    figure.where(kind: bilingual-figured.prefixed-kind(kind)),
  )
    .at(loc)
    .at(0, default: 0)
  if prefixed-index > 0 {
    prefixed-index
  } else {
    counter(figure.where(kind: kind)).at(loc).at(0, default: 1)
  }
}

#let _display-table-number(
  loc,
  numbering: "1-1",
  level: 1,
  zero-fill: true,
  leading-zero: true,
  kind: "bitable",
) = {
  let heading-prefix = _prepare-heading-prefix(
    loc,
    level: level,
    zero-fill: zero-fill,
    leading-zero: leading-zero,
  )
  let index = _table-index-at(loc, kind: kind)
  _typst-numbering(numbering, ..heading-prefix, index)
}

// 续页判断：给定位置页码是否晚于本表锚点页码。须在 context 内调用
// （内部含 query）。锚点 figure 经 show-figure 改写为 prefixed kind 后
// 才能被命中；`.before(loc)` 下本表锚点恒为最后一项，故取 last。
#let _is-continued(loc) = {
  let anchors = query(
    selector(
      figure.where(kind: bilingual-figured.prefixed-kind("bitable")),
    ).before(loc),
  )
  let anchor-page = if anchors.len() > 0 {
    anchors.last().location().page()
  } else {
    loc.page()
  }
  loc.page() > anchor-page
}

#let _source-caption-data(source) = {
  let extracted = bilingual-figured.extract-bilingual-caption(source)
  if extracted == none {
    (
      zh: none,
      en: none,
      supplement_zh: [表],
      supplement_en: [Table],
    )
  } else {
    (
      zh: extracted.zh,
      en: extracted.en,
      supplement_zh: extracted.supplement_zh,
      supplement_en: extracted.supplement_en,
    )
  }
}

#let _resolve-columns(columns) = {
  if type(columns) == int {
    (auto,) * columns
  } else {
    columns
  }
}

#let auto-table(
  caption-zh: none,
  caption-en: none,
  note: none,
  columns: auto,
  header: (),
  label: none,
  numbering: "1-1",
  // auto：按当前是否附录自动选"表/附表"。
  supplement-zh: auto,
  supplement-en: auto,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  style: (:),
  // 卧排（landscape）：true 时整表逆时针旋转 90°，顶左底右，适用于宽表。
  // 旋转内容不跨页，故强制 breakable:false 保证整体不分页。与 bifigure/bitable
  // 的 landscape 同语义，但 auto-table 不经 show-figure，须在此自行包裹 rotate。
  landscape: false,
  ..args,
) = {
  if caption-zh == none {
    panic("auto-table 需要提供 caption-zh")
  }
  if columns == auto {
    panic("auto-table 需要显式提供 columns")
  }

  let col-count = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    panic("auto-table 的 columns 需为整数或列宽数组")
  }

  let merged-style = _default-continuation-style + style
  let resolved-columns = _resolve-columns(columns)
  // 用户未显式 inset 时用收紧后的默认内边距，便于 auto 列按内容收缩
  let table-named = args.named()
  if "inset" not in table-named {
    table-named.insert("inset", merged-style.cell_inset)
  }
  // 默认三线表（规范二·（六）·6：尽量三线表、避免竖线）。
  // 用户传入 stroke 时尊重其选择；否则顶线/底线默认，栏目线 0.5pt。
  let three-line = "stroke" not in table-named
  if three-line {
    table-named.insert("stroke", none)
  }
  let rule-top = table.hline()
  let rule-mid = table.hline(stroke: 0.5pt)
  let rule-bot = table.hline()

  context {
    // 解析 supplement：附录中自动用"附表/Appendix Table"，正文用"表/Table"，
    // 用户显式传参时尊重其选择。与 show-figure 对 bifigure/bitable 的改写保持一致，
    // 使 auto-table 的正文标题、图表目录、续表页眉前缀全部统一。
    let appendix = bilingual-figured.in-appendix()
    let supp-zh = if supplement-zh == auto {
      bilingual-figured.resolve-supplement("bitable", none, appendix)
    } else {
      supplement-zh
    }
    let supp-en = if supplement-en == auto {
      if appendix { [Appendix Table] } else { [Table] }
    } else {
      supplement-en
    }

    let anchor-figure = figure(
      block(width: 0pt, height: 0pt)[],
      kind: "bitable",
      supplement: none,
      numbering: numbering,
      caption: metadata((
        zh: caption-zh,
        en: caption-en,
        note: note,
        supplement_zh: supp-zh,
        supplement_en: supp-en,
        render: false,
      )),
    )

    let anchor = if label != none {
      [#anchor-figure #label]
    } else {
      anchor-figure
    }

    // 表块。题注分两处渲染：
    // - 首页：表外题注（不占列宽，保住 auto 列按内容收缩）。
    // - 续页：规范要求「在续表表头上方注明续表」。Typst 只会重复 table.header，
    //   故在 header 顶部放两行 colspan 题注（中/英各一行），首页为空行（cell
    //   inset 为 0、无内容时高度塌缩），续页经页码比较写出「（续表）」。
    // 顶线放在题注行之后、列头之前，使续页版式为：中文题 → 英文题 → 顶线 → 列头，
    // 与规范样张一致。题注行用 block(inset:) 撑出上下间距（cell inset 保持 0）。
    let continued-cell(body) = table.cell(
      colspan: col-count,
      align: center,
      stroke: none,
      inset: (x: 0pt, y: 0pt),
    )[#body]
    let continued-zh-cell = continued-cell[
      #context {
        let loc = here()
        if _is-continued(loc) {
          let number = _display-table-number(
            loc,
            numbering: numbering,
            level: level,
            zero-fill: zero-fill,
            leading-zero: leading-zero,
          )
          // 中英题间距取 caption_gap（= 行距.正文），与表外题注的 v(caption_gap)
          // 同口径；否则两 header 行直接相贴，基线距仅 ~6.9pt、字形重叠。
          // set 须在 block 之前：inset 中的相对单位按此处字号解析，
          // 置于 text 内则回退到正文字号、间距偏大约 1.6pt。
          // 定宽盒：colspan 行宽被表体 auto 列收窄时，长题注会被迫折行
          // （首页表外题注为通栏则单行）。按自然宽度定宽装盒后在格内居中
          // 溢出、两侧对称，与首页同形。题注须短于通栏（首页能单行放下）。
          set text(..merged-style.zh_text)
          let cap = [#supp-zh #number #merged-style.separator #caption-zh#merged-style.continued_mark_zh]
          box(
            width: measure(cap).width,
            block(inset: (top: 8pt, bottom: merged-style.caption_gap), cap),
          )
        }
      }
    ]
    let continued-en-cell = if caption-en == none {
      none
    } else {
      continued-cell[
        #context {
          let loc = here()
          if _is-continued(loc) {
            let number = _display-table-number(
              loc,
              numbering: numbering,
              level: level,
              zero-fill: zero-fill,
              leading-zero: leading-zero,
            )
            // 英文题同中文题：定宽盒防窄表折行（见上）。
            set text(..merged-style.en_text)
            let cap = [#supp-en #number #merged-style.separator #caption-en#h(
                0.4em,
              )#merged-style.continued_mark_en]
            box(
              width: measure(cap).width,
              block(inset: (top: 0pt, bottom: 8pt), cap),
            )
          }
        }
      ]
    }
    let continued-rows = (
      continued-zh-cell,
      ..if continued-en-cell == none { () } else { (continued-en-cell,) },
    )

    let table-block = block(
      breakable: not landscape,
      width: 100%,
      above: 0pt,
      below: 0.9em,
      {
        context {
          // 首页题注在表外
          let loc = here()
          if not _is-continued(loc) {
            let number = _display-table-number(
              loc,
              numbering: numbering,
              level: level,
              zero-fill: zero-fill,
              leading-zero: leading-zero,
            )
            _render-caption-outside(
              number,
              caption-zh,
              caption-en,
              supp-zh,
              supp-en,
              merged-style,
            )
          }
        }
        set par(justify: false, leading: 行距.单倍, spacing: 行距.单倍)
        set align(merged-style.table_align)
        if three-line {
          table(
            columns: resolved-columns,
            ..table-named,
            // 续页：题注行 → 顶线 → 列头（顶线进 header，随页重复）
            table.header(..continued-rows, rule-top, ..header),
            rule-mid,
            ..args.pos(),
            rule-bot,
          )
        } else {
          table(
            columns: resolved-columns,
            ..table-named,
            table.header(..continued-rows, ..header),
            ..args.pos(),
          )
        }
        _render-note(note, merged-style)
      },
    )

    // 卧排（landscape）：整表逆时针旋转 90°，使表顶朝页面左侧、表底朝右侧，
    // 符合 UCAS 规范"顶左底右"。reflow: true 让旋转后包围盒重算，正确影响布局
    // （Typst 官方 tables 指南方案）。auto-table 的 caption 在表头内渲染（非
    // figure.caption），随 table-block 一同旋转，方位一致。旋转内容不跨页，
    // 上方已 breakable:false。
    if landscape {
      [#anchor #rotate(-90deg, reflow: true, table-block)]
    } else {
      [#anchor #table-block]
    }
  }
}

#let continued-table(
  source,
  caption-zh: auto,
  caption-en: auto,
  supplement-zh: auto,
  supplement-en: auto,
  note: none,
  numbering: "1-1",
  level: 1,
  zero-fill: true,
  leading-zero: true,
  kind: "bitable",
  style: (:),
  body,
) = context {
  let matched = query(source)
  if matched.len() == 0 {
    panic("continued-table 未找到源表标签: " + repr(source))
  }

  let origin = matched.first()
  let source-data = _source-caption-data(origin)
  let zh = if caption-zh == auto { source-data.zh } else { caption-zh }
  let en = if caption-en == auto { source-data.en } else { caption-en }
  let supp-zh = if supplement-zh == auto {
    source-data.supplement_zh
  } else {
    supplement-zh
  }
  let supp-en = if supplement-en == auto {
    source-data.supplement_en
  } else {
    supplement-en
  }

  if zh == none {
    panic("continued-table 需要 caption-zh，或确保源表具有双语标题元数据")
  }

  // 续表编号必须与原表一致（章节号 + 表序号），故沿用 auto-table 的
  // _display-table-number，而非 display-figure-number——后者只取 figure
  // 计数器单值，会把章节号位错填成表序号，渲染成「表 1」而非「表 1-1」。
  let number = _display-table-number(
    origin.location(),
    numbering: numbering,
    level: level,
    zero-fill: zero-fill,
    leading-zero: leading-zero,
    kind: kind,
  )
  let merged-style = _default-continuation-style + style

  // 外层 block 必须占满正文宽度（width: 100%），否则 block 按内容收缩后
  // 被置于页面左侧，_render-caption 内部的 set align(center) 只能让标题在
  // 收缩后的小 block 内居中，整体仍偏左。auto-table 同样以 width: 100% 解决。
  block(width: 100%, ..merged-style.continued_block)[
    #_render-caption(
      number,
      zh,
      en,
      supp-zh,
      supp-en,
      merged-style,
      continued: true,
    )
    #align(merged-style.table_align)[
      #body
    ]
    #_render-note(note, merged-style)
  ]
}
