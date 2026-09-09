// 定理类数学环境（对齐 ucasthesis/LaTeX amsthm）：
// - plain 共用计数器：公理/定理/引理/推论/断言/命题/猜想
// - definition / example 各自计数
// - 注（remark）不编号；证明（proof）以黑色方框结束
// - 编号形如「定理 1-1」，随章重置；重置由 mainmatter 在一级标题处调用
//   reset-theorem-counters()。
// - 交叉引用：`thm:` 等前缀（见 _thm-refspec），如 `@thm:pyth`；量词默认手写
//   （`ref-supplements: none` 时引用为裸编号），auto/字典模式由
//   show-theorem-ref 自动补量词（经 mainmatter/appendix 注册）。

#let _ctr-plain = counter("thm-plain")
#let _ctr-def = counter("thm-def")
#let _ctr-ex = counter("thm-ex")

#let reset-theorem-counters() = {
  _ctr-plain.update(0)
  _ctr-def.update(0)
  _ctr-ex.update(0)
}

// 引用前缀 →（计数器，量词，字典组键）。前缀即标签前缀（`lem:` attach 到引理，
// `@lem:` 引用），组键用于 ref-supplements 字典（thm/def/ex 三组）。
#let _thm-refspec = (
  thm: (ctr: _ctr-plain, word: [定理], group: "thm"),
  axm: (ctr: _ctr-plain, word: [公理], group: "thm"),
  lem: (ctr: _ctr-plain, word: [引理], group: "thm"),
  cor: (ctr: _ctr-plain, word: [推论], group: "thm"),
  ast: (ctr: _ctr-plain, word: [断言], group: "thm"),
  prp: (ctr: _ctr-plain, word: [命题], group: "thm"),
  cnj: (ctr: _ctr-plain, word: [猜想], group: "thm"),
  def: (ctr: _ctr-def, word: [定义], group: "def"),
  ex: (ctr: _ctr-ex, word: [例], group: "ex"),
)

#let _qed-mark = box(
  width: 0.55em,
  height: 0.55em,
  fill: black,
  baseline: 0.15em,
)

// 环境主体：加粗标题 + 直立正文（中文论文不用 amsthm plain 的斜体正文）。
// 编号「章-序」与图/表/公式一致；关闭首行缩进，避免继承正文 2em。
#let _thm-block(body) = block(above: 1.2em, below: 1.2em, {
  set par(first-line-indent: 0pt)
  body
})

// 标题文本（标题与引用共用，保证两处编号恒一致）。
#let _thm-title(word, chapter, n, name: none) = if name == none {
  [*#word #{ chapter }-#{ n }*]
} else {
  [*#word #{ chapter }-#{ n }（#name）*]
}

// kind-word: 题注用词（定理/引理/定义/例…）；ctr: 对应组计数器。
// ctr.step() 置于 block 内部首位（官方 counter 文档模式）：返回单个 block
// 元素，用户尾随的 <thm:> 标签附着其上、被 @ 引用。切勿改用 figure 载体：
// figure 隐式 step 会与 show 规则重建的新 figure 各计一次（标题 double），
// 且重建前后的 kind/计数器/label 改名链条脆弱，实测已证伪（见审计记录）。
#let _thm-env(kind-word, ctr, name: none, body) = {
  _thm-block[
    #ctr.step()
    #context {
      let chapter = counter(heading).get().at(0, default: 0)
      let n = ctr.get().first()
      [#_thm-title(kind-word, chapter, n, name: name)#h(0.75em)]
    }
    #body
  ]
}

// --- plain 样式（共用计数器） ---
#let axiom(name: none, body) = _thm-env("公理", _ctr-plain, name: name, body)
#let theorem(name: none, body) = _thm-env("定理", _ctr-plain, name: name, body)
#let lemma(name: none, body) = _thm-env("引理", _ctr-plain, name: name, body)
#let corollary(name: none, body) = _thm-env(
  "推论",
  _ctr-plain,
  name: name,
  body,
)
#let assertion(name: none, body) = _thm-env(
  "断言",
  _ctr-plain,
  name: name,
  body,
)
#let proposition(name: none, body) = _thm-env(
  "命题",
  _ctr-plain,
  name: name,
  body,
)
#let conjecture(name: none, body) = _thm-env(
  "猜想",
  _ctr-plain,
  name: name,
  body,
)

// --- definition 样式（独立计数） ---
#let definition(name: none, body) = _thm-env("定义", _ctr-def, name: name, body)
#let example(name: none, body) = _thm-env("例", _ctr-ex, name: name, body)

// --- remark：不编号（不接受引用标签） ---
#let remark(body) = _thm-block[
  *注.*#h(0.75em)#body
]

// --- proof：右下角黑色方框（不接受引用标签） ---
#let proof(body) = _thm-block[
  *证明.*#h(0.75em)#body#h(1fr)#_qed-mark
]

// 定理类引用渲染（由 mainmatter/appendix 以 show ref 注册，ref-supplement
// 随 documentclass 的 ref-supplements 传入）：
// - 只处理 `thm:` 等九前缀的引用，其余原样返回（与 citation-range-hyphen
//   互不干扰：双方都只认自己的目标类型；form 非 normal（如 page）时交还原生）。
// - 编号经显式 `#ref` 无法自动推导（block 无 numbering），故在此按章重组，
//   与标题同一公式（`_thm-title` 的无样式版），天然一致。
// - 计数读取：标签位点的 `at` 取值不含块内首个 step（at 语义为严格之前，
//   实测），故 +1；标题在 step 之后直接 get，两者对齐。
#let show-theorem-ref(it, ref-supplement: none) = {
  if not it.has("target") {
    return it
  }
  let parts = str(it.target).split(":")
  if parts.len() < 2 or parts.first() not in _thm-refspec {
    return it
  }
  if it.has("form") and it.form != "normal" {
    return it
  }
  let spec = _thm-refspec.at(parts.first())
  let loc = it.element.location()
  let chapter = counter(heading).at(loc).at(0, default: 0)
  let n = spec.ctr.at(loc).first() + 1
  let number = numbering("1-1", chapter, n)
  // 量词：用户显式 supplement 优先；否则 none 裸编号，auto 随种类，
  // 字典取 thm/def/ex 组键（缺省回落种类用词）。
  let supp = if it.has("supplement") and it.supplement != auto {
    it.supplement
  } else if ref-supplement == none {
    none
  } else if ref-supplement == auto {
    spec.word
  } else {
    ref-supplement.at(spec.group, default: spec.word)
  }
  if supp == none {
    link(loc, number)
  } else {
    link(loc, [#supp #number])
  }
}
