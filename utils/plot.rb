#!/usr/bin/ruby
# -*- mode: ruby; coding: UTF-8 -*-

require 'yaml'

sheets = Dir.glob("sheet/sheet-*")

case ARGV[0]
when "in"
  sheets.each_with_index do |sheetf, index|
    sheet = YAML.load File.read sheetf
    puts sheet["in"].values.sum
  end
when "out"
  sheets.each_with_index do |sheetf, index|
    sheet = YAML.load File.read sheetf
    puts sheet["out"].map {|k, v| v&.values || 0}.flatten.sum
  end
when "plot"
  system "gnuplot", "-p", "-e", %q:plot '< ruby plot.rb in' using 1 w l title 'IN', '< ruby plot.rb out' using 1 w l title 'OUT':
when "list"
  sheets.each do |sheetf|
    sheet = YAML.load File.read sheetf
    iv = sheet["in"].values.sum
    ov = sheet["out"].map {|k, v| v&.values || 0}.flatten.sum
    d = iv - ov
    ansi = d < 0 ? "\e[35m" : "\e[32m"
    printf("%s: \e[36m%8d\e[0m \e[33m%8d\e[0m %s(%+8d)\e[0m\n", sheetf.sub(/.*-/, "").sub(/\.yaml$/, ""), iv, ov, ansi, d)
  end
end