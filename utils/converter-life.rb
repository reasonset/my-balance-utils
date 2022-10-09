#!/usr/bin/ruby
require 'yaml'
require 'csv'
require_relative 'converter-utils'

normal_line = []
split_line = []

datafile = ARGF.read.encode(Encoding::UTF_8, Encoding::CP932).unicode_normalize(:nfkc).gsub("\r\n", "\n")

datafile.each_line do |line|
  if line =~ /^明細No\.,契約,/ ... line =~ /^$/
    normal_line.push(line)
  end
end

normal_line.shift
normal_line.pop

detail = CSV.parse(normal_line.join)

record = Record.new

detail.each do |i|
  date = i[3][5, 5]
  name = i[4]
  cpart = if i[2] == "分割"
    i[9] =~ %r:(\d+)/(\d+):
    "(#$2/#$1)"
  else
    nil
  end
  value = i[10].to_i

  record.checkout date, name, cpart, value
end

YAML.dump({"out" => record.finish}, STDOUT)
