#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": get-fonts
#import "../utils/page-foreground.typ": mainmatter-foreground

// 致谢页
#let acknowledgement(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 致谢末尾日期，与论文封面 submit-date 一致
  // 传 datetime 自动格式化为"YYYY 年 M 月"；传字符串/内容则原样使用；传 none 不显示
  date: none,
  // 其他参数
  title: [致#h(1em)谢],
  outlined: true,
  body,
) = {
  if (not anonymous) {
    // 起始三件套（P30）：先清样式（填充页干净），再换页，最后重申正文域样式。
    fonts = get-fonts(fontset) + fonts
    set page(numbering: none, foreground: none)
    pagebreak(weak: true, to: if twoside { "odd" })
    set page(
      numbering: "1",
      footer: none,
      foreground: mainmatter-foreground(
        twoside: twoside,
        info: info,
        fonts: fonts,
      ),
    )
    [
      #heading(
        level: 1,
        numbering: none,
        outlined: outlined,
        title,
      ) <no-auto-pagebreak>

      #body

      #if date != none {
        let date-content = if type(date) == datetime {
          datetime-display(date)
        } else {
          date
        }
        // 末尾右对齐日期
        align(right, date-content)
      }
    ]
  }
}
