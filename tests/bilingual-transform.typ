// 双语参考文献转换回归测试（等 / 译 / 卷 / 版）。
// 运行：typst compile tests/bilingual-transform.typ --root .
// 目测检查点（PDF 文本抽取应包含）：
//   "2nd ed"（"第2版"）、"Vol. 3"（"第3卷"）、"et al."（"等"）、"， trans"（"译"）
// 注：译 例的 "…[M]. 李, 译" 为构造性 title（真实 CSL 条目中"译"多出现于
// 被判为中文文献的条目，不触发该分支），仅用于覆盖替换分支本身。
// 背景见 utils/bilingual-bibliography.typ 头部升级警示：转换逻辑挂载于
// grid.cell.where(x: 1)，依赖 Typst bibliography 内部 grid 布局（未文档化）。
// 升级 Typst 后若本测试转换静默失效，应优先排查该处。
#import "../utils/bilingual-bibliography.typ": bilingual-bibliography

#set page(width: 14cm, height: auto, margin: 2cm)

#bilingual-bibliography(
  bibliography: bibliography.with("ref-test.bib"),
  full: true,
  info: (title: "双语转换回归测试"),
  title: [双语转换回归测试],
)
