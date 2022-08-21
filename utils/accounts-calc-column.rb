#!/usr/bin/ruby

file_list = []
monthly = {}
total = {}

ARGV.each do |file|
  file_list.push(file)
  last_val = nil
  File.foreach(file) do |line|
    val = line.chomp.split(" ", 2)
    month = val.shift
    val[0] = last_val if val[0] == "-"
    i = val[0].to_i
    last_val ||= i
    d = i - last_val
    val.push(d < 0 ? "\e[35m" : "\e[32m")
    val.push(d)
    monthly[month] ||= {
      accounts: [],
      total: 0,
      total_diff: 0
    }
    monthly[month][:accounts].push sprintf("%8d %s(%+8d)\e[0m", *val)
    monthly[month][:total] += i
    monthly[month][:total_diff] += d
    last_val = i
  end
end

puts("Month   " + file_list.map {|i| sprintf("%19s", File.basename(i))}.join(" ") + "|" + sprintf("%19s", "TOTAL"))
puts("-" * (8 + 19 * file_list.length + (file_list.length - 1)) + "+" + "-"  * 19)

monthly.keys.sort.each do |k|
  v = monthly[k][:total]
  d = monthly[k][:total_diff]
  ansi = d < 0 ? "\e[35m" : "\e[32m"
  printf("%s: %s|%8d %s(%+8d)\e[0m\n", k, monthly[k][:accounts].join(" "), v, ansi, d)
end