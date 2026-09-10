// 一个简单的自定义 Numbering
// 用法也简单，可以特殊设置一级等标题的样式，以及一个缺省值
#let custom-numbering(
  base: 1,
  depth: 5,
  first-level: auto,
  second-level: auto,
  third-level: auto,
  format,
  ..args,
) = {
  let pos = args.pos()
  if pos.len() > depth {
    return
  }
  if first-level != auto and pos.len() == 1 {
    if first-level != "" {
      numbering(first-level, ..args)
    }
    return
  }
  if second-level != auto and pos.len() == 2 {
    if second-level != "" {
      numbering(second-level, ..args)
    }
    return
  }
  if third-level != auto and pos.len() == 3 {
    if third-level != "" {
      numbering(third-level, ..args)
    }
    return
  }
  // default
  if pos.len() >= base {
    numbering(format, ..(pos.slice(base - 1)))
    return
  }
}
