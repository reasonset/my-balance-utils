#!/usr/bin/ruby

total_count = Hash.new(0)
total_diff = Hash.new(0)

ARGV.each do |file|
  last_val = nil
  puts "\e[36m*** #{File.basename(file)}\e[0m"
  File.foreach(file) do |line|
    val = line.chomp.split(" ")
    i = val[1].to_i
    last_val ||= i
    d = i - last_val
    val.push(d < 0 ? "\e[35m" : "\e[32m")
    val.push(d)
    printf("\e[34m%s:\e[0m %8d %s(%+8d)\e[0m\n", *val)
    last_val = i
    total_count[val[0]] += i
    total_diff[val[0]] += d
  end
  puts
end

puts "\e[36m##### TOTAL COUNT #####\e[0m"
total_count.each_key do |k|
  v = total_count[k]
  d = total_diff[k]
  ansi = d < 0 ? "\e[35m" : "\e[32m"
  printf("%s: %8d (%s%+8d\e[0m)\n", k, v, ansi, d)
end