// 前言 / 正文页眉页脚 foreground 工厂。
//
// 使用方式：各部分起始处先 set page(foreground: ...) 再 pagebreak，使双面模式下
// to:"odd" 换页自动插入的填充空白页与正文页一样显示页眉页脚
//（偶数页题目、奇数页章名/部分名）。
// 页眉/页脚距页边界 1.5cm 由 place 绝对定位实现，字体宋体小五
//（数字走 Times 回退），见各函数内注释。

#import "style.typ": 字号
#import "custom-numbering.typ": 编号自动间隙

// —— 共用 helper（preface / mainmatter 两个 foreground 工厂重复逻辑的单点实现）——

// 论文题目 content 渲染：数组题目直接拼接，其余转 str。
#let _title-content(thesis-title) = if type(thesis-title) == array {
  thesis-title.join("")
} else {
  str(thesis-title)
}

// 奇数页页眉内容：当前页的一级标题，当前页没有则取之前最近的一级标题。
// doctype 为 "bachelor" 时补回编号模板中的负空格（见下），研究生不补。
#let _odd-page-header-content(doctype: "doctor") = context {
  let current-page = here().page()
  let current-headings = query(heading.where(level: 1)).filter(
    h => h.location().page() == current-page,
  )
  let filtered-headings = if current-headings.len() > 0 {
    current-headings
  } else {
    query(selector(heading.where(level: 1)).before(here()))
  }
  let current-heading = if filtered-headings.len() > 0 {
    filtered-headings.last()
  } else { none }

  let header-content = ""
  if current-heading != none {
    if (
      current-heading.has("numbering") and current-heading.numbering != none
    ) {
      let counter-values = counter(heading).at(current-heading.location())
      // 直接调用 heading 自身的 numbering 渲染章序号，
      // 而非硬编码"第1章"——这样附录（first-level 为空）的页眉
      // 不会错误显示"第1章"，而显示纯标题（如"附录"）。
      // 序号与章名间的"一个汉字符"由 numbering 模板内的全角空格 U+3000（1em）提供。
      // 本科编号模板另带 -编号自动间隙（抵消标题渲染中 Typst 自动追加的间隙，
      // 见 utils/custom-numbering.typ），页眉不经过标题渲染、没有那一段自动间隙，
      // 故本科在此补回，使净距同样为 1em；研究生编号无负空格，不补。
      let number-content = (current-heading.numbering)(..counter-values)
      header-content = if doctype == "bachelor" {
        number-content + h(编号自动间隙)
      } else {
        number-content
      }
    }
    header-content += current-heading.body
  } else {
    header-content = "没有找到章标题"
  }
  header-content
}

// 页眉渲染：距页面顶边 1.5cm，宋体小五号，居中，下方 0.5em 处加分隔线。
// display-header 为 false 时省略页眉（仅保留 footnote 重置与页脚页码）。
// doctype 为 "bachelor" 时分隔线约束到正文区宽度（见分支内注释）；研究生分支
// 保持既有代码，输出与既有版本完全一致（分隔线按 place 容器即整页宽度绘制）。
// 说明：place 容器是整个页面，故 line(length: 100%) 直接写在 place 体内会横贯整页，
// 须放进宽度受约束的 block 才会解析为版心宽（官方样稿的分隔线即版心宽）。
#let _place-header(
  header-content,
  fonts,
  stroke-width,
  doctype: "doctor",
) = place(
  top + center,
  dy: 1.5cm,
  {
    set text(
      font: fonts.宋体,
      size: 字号.小五,
      top-edge: "bounds",
      bottom-edge: "bounds",
    )
    // 行距段距清零：默认 par spacing（1.2em）会把分隔线顶到 16pt 开外
    //（LaTeX 参考仅约 4pt）；清零后由下方显式 v(2pt) 精确定位。
    set par(leading: 0pt, spacing: 0pt)
    if doctype == "bachelor" {
      // 页眉盒顶定位于距页边界 1.5cm（与 LaTeX headheight 盒模型一致，
      // 盒高 12pt，文字底对齐，基线约 1.5cm+12pt；分隔线在盒下 0.5em）。
      // 文字盒与分隔线同处宽度受约束的 block 内，line 的 100% 才是版心宽
      //（用代码块逐个书写，避免在 markup 块内漏写 # 而变成字面文字）。
      block(
        width: 100% - 3.17cm - 3.17cm,
        {
          block(height: 12pt, align(center + bottom, header-content))
          v(2pt)
          line(length: 100%, stroke: stroke-width + black)
        },
      )
    } else {
      block(width: 100% - 3.17cm - 3.17cm, height: 12pt)[
        #align(center + bottom, header-content)
      ]
      v(2pt)
      line(length: 100%, stroke: stroke-width + black)
    }
  },
)
}

// 前言 foreground：页码大写罗马数字居中；奇数页章名、偶数页题目
//（英文摘要偶数页用英文题目）。
#let preface-foreground(
  info: (:),
  fonts: (:),
  display-header: true,
  stroke-width: 0.8pt,
  reset-footnote: true,
  doctype: "doctor",
) = context {
  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 获取当前页码
  let current-page = counter(page).get().first()

  // 判断是否为奇数页
  let is-odd-page = calc.odd(current-page)

  // 初始化页眉
  let header-content = ""

  if is-odd-page {
    // 奇数页：显示当前页的一级标题
    header-content = _odd-page-header-content()
  } else {
    // 偶数页：显示论文标题
    // 规范：英文摘要偶数页标明英文题目，其余前置部分标明中文题目。
    // 判断方法：查询当前位置之前最近的一级标题（与奇数页分支同源 query 模式），
    // 若其文本含 "Abstract" 则当前处于英文摘要部分，用 info.title-en；否则用 info.title。
    let current-page-num = here().page()
    let current-headings = query(heading.where(level: 1)).filter(
      h => h.location().page() == current-page-num,
    )
    let recent-heading = if current-headings.len() > 0 {
      current-headings.last()
    } else {
      let before-headings = query(
        selector(heading.where(level: 1)).before(here()),
      )
      if before-headings.len() > 0 { before-headings.last() } else {
        none
      }
    }

    // 递归把 content 转为 str（与 bilingual-bibliography.typ 的 to-string 同构）
    let content-to-str(c) = {
      if c == none { "" } else if type(c) == str { c } else if c.has("text") {
        c.text
      } else if c.has("children") {
        c.children.map(content-to-str).join("")
      } else if c.has("child") { content-to-str(c.child) } else if c.has(
        "body",
      ) { content-to-str(c.body) } else if c.has("supplement") {
        content-to-str(c.supplement)
      } else { "" }
    }

    let heading-text = content-to-str(
      if recent-heading != none { recent-heading.body } else { none },
    )
    let thesis-title = if heading-text.contains("Abstract") {
      info.title-en
    } else {
      info.title
    }

    if thesis-title != none {
      header-content = _title-content(thesis-title)
    }
    if header-content == "" {
      header-content = "没有找到标题"
    }
  }

  // 渲染页眉（共用 helper，见 _place-header）
  if display-header {
    _place-header(header-content, fonts, stroke-width, doctype: doctype)
  }

  // 渲染页脚（页码）：距页面底边 1.5cm，宋体小五号居中，大写罗马数字
  place(
    bottom + center,
    dy: -1.5cm,
    {
      set text(
        font: fonts.宋体,
        size: 字号.小五,
        top-edge: "bounds",
        bottom-edge: "bounds",
      )
      counter(page).display("I")
    },
  )
}

// 正文 foreground：页码阿拉伯数字（单面居中，双面奇右偶左）；
// 奇数页章名、偶数页论文题目。
#let mainmatter-foreground(
  twoside: false,
  info: (:),
  fonts: (:),
  display-header: true,
  stroke-width: 0.8pt,
  reset-footnote: true,
  doctype: "doctor",
) = context {
  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 获取当前页码
  let current-page = counter(page).get().first()

  // 判断是否为奇数页
  let is-odd-page = calc.odd(current-page)

  // 初始化页眉
  let header-content = ""

  if is-odd-page {
    // 奇数页：显示当前页的一级标题（共用 helper，见 _odd-page-header-content）
    header-content = _odd-page-header-content(doctype: doctype)
  } else {
    // 偶数页：显示论文标题
    let thesis-title = info.title
    if thesis-title != none {
      header-content = _title-content(thesis-title)
    }
    if header-content == "" {
      header-content = "没有找到标题"
    }
  }

  // 渲染页眉（共用 helper，见 _place-header）
  if display-header {
    _place-header(header-content, fonts, stroke-width, doctype: doctype)
  }

  // 渲染页脚（页码）：距页面底边 1.5cm，宋体小五号。
  // 单面居中；双面奇数页(右页)右对齐、偶数页(左页)左对齐。
  // 本科显式清零段落样式：page.foreground 会继承正文作用域内的 par 规则，
  // mainmatter 的 first-line-indent 会使左对齐的偶数页页码相对左边距内缩 2em
  //（实测 18pt）。set 规则只作用于同一块内的后续内容（实测），故与内容同块书写；
  // 研究生分支不加任何样式，输出与既有版本完全一致。
  let number-align = if twoside and calc.even(current-page) {
    left
  } else if twoside {
    right
  } else { center }
  place(
    bottom + center,
    dy: -1.5cm,
    {
      set text(
        font: fonts.宋体,
        size: 字号.小五,
        top-edge: "bounds",
        bottom-edge: "bounds",
      )
      if doctype == "bachelor" {
        set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
        block(width: 100% - 3.17cm - 3.17cm)[
          #align(number-align, counter(page).display("1"))
        ]
      } else {
        block(width: 100% - 3.17cm - 3.17cm)[
          #align(number-align, counter(page).display("1"))
        ]
      }
    },
  )
}
