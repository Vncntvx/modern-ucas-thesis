// 个人信息
#import "../utils/style.typ": get-fonts
#import "../utils/page-foreground.typ": mainmatter-foreground

#let backmatter(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  title: [作者简历及攻读学位期间发表的学术论文与其他相关学术成果],
  outlined: true,
  body,
) = {
  if (not anonymous) {
    // 起始页面样式：先设置页眉页脚（page.foreground）再换页，使双面模式下
    // to:"odd" 换页自动插入的填充空白页同样显示页眉页脚（偶数页论文题目、
    // 奇数页章名，页码按双面左右分置）。
    // 标题（黑体四号加粗居中）与正文字体行距继承自外层 mainmatter 作用域
    // （show 规则嵌套，标准顺序下本函数位于其内），此处不重复设置。
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
    [
      #heading(
        level: 1,
        numbering: none,
        outlined: outlined,
        title,
      ) <no-auto-pagebreak>
      #set par(first-line-indent: (amount: 0pt, all: true))

      #body
    ]
  }
}
