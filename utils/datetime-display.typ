// 中文日期：研究生封面与致谢用（"20XX 年 X 月"）。
#let datetime-display(date) = {
  date.display("[year] 年 [month padding:none] 月")
}

// 中文日期紧凑式：本科封面与致谢用（"20XX年X月"，对齐本科样张"2023年6月"）。
#let datetime-display-compact(date) = {
  date.display("[year]年[month padding:none]月")
}

// 英文日期：研究生封面用（"Sep, 20XX"）。
#let datetime-en-display(date) = {
  date.display("[month repr:short], [year]")
}

// 英文日期全称式：本科封面用（"June 20XX"，对齐本科样张）。
#let datetime-en-display-long(date) = {
  date.display("[month repr:long] [year]")
}
