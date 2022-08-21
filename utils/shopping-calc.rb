#!/bin/ruby
require 'date'

SHOPPINGS = Hash.new {|h, k| h[k] = []}

def colorcode(val, n=1)
  case val
  when (0 * n)..(1000 * n)
    "\e[38;5;33m"
  when (1000 * n)..(2500 * n)
    "\e[38;5;69m"
  when (2500 * n)..(4000 * n)
    "\e[38;5;105m"
  when (4000 * n)..(7500 * n)
    "\e[38;5;141m"
  when (7500 * n)..(10000 * n)
    "\e[38;5;177m"
  when (10000 * n)..(15000 * n)
    "\e[38;5;213m"
  when (15000 * n)..(20000 * n)
    "\e[38;5;201m"
  else
    "\e[38;5;196m"
  end
end


Dir.glob("shopping/*").each do |fp|
  File.foreach(fp) do |l|
    next if l =~ /^$/
    v = l.split("\t")
    SHOPPINGS[Date.parse v[0]].push({
      value: v[1].to_i,
      term: v[2].to_s.chomp,
      description: v[3].to_s.chomp
    })
  end
end

TARGET_FACTOR = ARGV.shift
TARGET = case TARGET_FACTOR
when "w"
  Date.today - 7
when "m"
  Date.today.prev_month
when /([^d]+)m/
  today = Date.today
  $1.to_i.times { today = today.prev_month }
  today
when /\d{2,4}-\d{2}-\d{2}/
  Date.parse(TARGET_FACTOR)
else
  abort "Not supported."
end

selected_keys = SHOPPINGS.keys.select {|k| k >= TARGET }.sort

puts "DATE        |VALUE   |DESCRIPTION"
puts "------------+--------+----------------------------------------------------"

total = 0
selected_keys.each do |k|
  SHOPPINGS[k].each do |i|
    printf("%12s|%s%8d%s|%s\n", k, colorcode(i[:value]), i[:value], "\e[0m", i[:term])
    total += i[:value]
  end
end

total_factor = case TARGET_FACTOR
when "w"
  1
when /([\d]+)m/
  4 * $1.to_i
else
  4
end

puts "------------+--------+----------------------------------------------------"
printf "TOTAL       |%s%8d%s|\n", colorcode(total, total_factor), total, "\e[0m"