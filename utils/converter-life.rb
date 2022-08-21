#!/usr/bin/ruby
require 'yaml'
require 'csv'

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

namemap = YAML.load(File.read("namemap.yaml"))
namemap.default_proc = ->(h, k) { k }

record = {}

detail.each do |i|
  splitter = if i[2] == "分割"
    i[9] =~ %r:(\d+)/(\d+):
    "(#$2/#$1)"
  else
    ""
  end

  record[ sprintf('%s-%s%s', i[3][5, 5], namemap[i[4]], splitter ) ] = i[10].to_i
end

YAML.dump({"out" => {"category" => record}}, STDOUT)
