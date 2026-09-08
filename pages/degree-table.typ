// 学位类别中英文对照表（规范附件 2），无编号展示性表格（P18）。
//
// 用法：#degree-table()，置于附录等处。不参与图表编号、不收录于图表目录
// （与需引用的 bitable 表格互补）。内容与 thesis.typ 原内联实现一致，
// 抽取为可复用组件。

#let degree-table() = {
  align(center)[#strong[学位类别中英文对照表]]

  let scd = [学术型\ 博士]
  let scm = [学术型\ 硕士]
  let pd = [专业学位\ 博士]
  let pm = [专业学位\ 硕士]
  let dp = [Doctor of Philosophy]
  set par(leading: 0.65em)
  // @typstyle off
  table(
    columns: (auto, auto, auto),
    align: (center, center, center),
    table.header([学位类别], [中文名称], [英文名称]),
    table.cell(rowspan: 8, align: horizon, scd), [哲学博士], table.cell(rowspan: 8, align: horizon, dp),
    [经济学博士], [历史学博士], [理学博士],
    [工学博士], [农学博士], [医学博士],
    [管理学博士],
    table.cell(rowspan: 10, align: horizon, scm), [哲学硕士], [Master of Philosophy],
    [经济学硕士], [Master of Economics],
    [法学硕士], [Master of Law],
    [文学硕士], [Master of Arts],
    [历史学硕士], [Master of History],
    [理学硕士], [Master of Natural Science],
    [工学硕士], [Master of Science in Engineering],
    [农学硕士], [Master of Agriculture],
    [医学硕士], [Master of Medicine],
    [管理学硕士], [Master of Management Science],
    [专业学位\ 博士], [材料与化工博士\*], [Doctor of Materials and Chemical\ Engineering],
    table.cell(rowspan: 17, align: horizon, pm), [金融硕士], [Master of Finance],
    [应用统计硕士], [Master of Applied Statistics],
    [应用心理硕士], [Master of Applied Psychology],
    [翻译硕士], [Master of Translation and Interpreting],
    [工程硕士（调整前）\*], [Master of Engineering],
    [电子信息硕士\*], [Master of Electronic and Information\ Engineering],
    [机械硕士\*], [Master of Mechanical Engineering],
    [材料与化工硕士\*], [Master of Materials and Chemical Engineering],
    [资源与环境硕士\*], [Master of Resources and Environmental\ Engineering],
    [能源动力硕士\*], [Master of Energy and Power Engineering],
    [土木水利硕士\*], [Master of Civil and Hydraulic Engineering],
    [生物与医药硕士\*], [Master of Biological and Pharmaceutical\ Engineering],
    [农业硕士], [Master of Agriculture],
    [药学硕士], [Master of Pharmacy],
    [工商管理硕士], [Master of Business Administration],
    [公共管理硕士], [Master of Public Administration],
    [工程管理硕士], [Master of Engineering Management],
  )
}
