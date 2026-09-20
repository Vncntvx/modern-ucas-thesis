// 标题编号与题名之间的净距控制。
//
// Typst 会在标题编号内容之后自动追加一段间隙（官方文档未记载；实测 Typst 0.15.1
// 为 0.3em，四号 4.2pt、小四 3.6pt，随标题字号等比）。规范要求"序号与题名间空
// 一个汉字符"，而编号模板内已含全角空格 U+3000（1em），故用等长负空格抵消该自动
// 间隙，使标题处净距恰为 1em。三个消费点须一致（净距 1em）：
// - 标题：编号内容（1em）+ 自动间隙（0.3em）+ suffix（-0.3em）；
// - 目录条目：不经过标题渲染、无自动间隙，由 outline-page 的 h(gap) 补回 0.3em；
// - 页眉：直接拼接编号与题名，由 page-foreground 显式补回 0.3em。
// 该结论依赖编译器行为，升级 Typst 后须复核（见 docs/CUSTOMIZE.md §8.6）。
#let 编号自动间隙 = 0.3em

// 一个简单的自定义 Numbering
// 用法也简单，可以特殊设置一级等标题的样式，以及一个缺省值。
// suffix：追加在编号内容之后（如 h(-编号自动间隙)），默认 none 不追加；
// 仅在确实输出编号时追加，first-level 为空（附录）等无编号情形保持 none。
#let custom-numbering(
  base: 1,
  depth: 5,
  first-level: auto,
  second-level: auto,
  third-level: auto,
  suffix: none,
  format,
  ..args,
) = {
  let pos = args.pos()
  let emit(fmt, nums) = {
    if fmt == "" {
      none
    } else if suffix == none {
      numbering(fmt, ..nums)
    } else {
      numbering(fmt, ..nums) + suffix
    }
  }
  if pos.len() > depth {
    return
  }
  if first-level != auto and pos.len() == 1 {
    return emit(first-level, args.pos())
  }
  if second-level != auto and pos.len() == 2 {
    return emit(second-level, args.pos())
  }
  if third-level != auto and pos.len() == 3 {
    return emit(third-level, args.pos())
  }
  // default
  if pos.len() >= base {
    return emit(format, pos.slice(base - 1))
  }
}

// 脚注圈码编号（规范二·（七）·2·（1）：每页单独用 ①②③ 等编码）。
// 圈码 ①–⑩（U+2460–U+2469）为各字体族共有字形（GB2312 序号区）；⑪ 起
// （U+246A 以上）在宋体、仿宋、Fandol 等字体中均缺字形，故第 11 条起回落
// 阿拉伯数字，避免出现豆腐块。每页重置由 page-foreground 的 reset-footnote 负责。
#let circled-footnote-numbering(n) = if n >= 1 and n <= 10 {
  numbering("①", n)
} else {
  numbering("1", n)
}
