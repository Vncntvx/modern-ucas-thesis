// 双端对齐一段小文本，常用于表格的中文 key。
// 内部 helper（不经 lib.typ 导出），仅接受 str：实现依赖 str.split("")，
// 传 content 会硬报错且错误指向内部，故入口显式断言给出可读信息。
#let justify-text(with-tail: false, tail: "：", body) = {
  assert(
    type(body) == str,
    message: "justify-text 需要 str 参数（如 \"作者姓名：\"），不接受 content。",
  )
  if with-tail and tail != "" {
    stack(
      dir: ltr,
      stack(dir: ltr, spacing: 1fr, ..body.split("").filter(it => it != "")),
      tail,
    )
  } else {
    stack(dir: ltr, spacing: 1fr, ..body.split("").filter(it => it != ""))
  }
}
