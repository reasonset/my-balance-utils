#!/bin/ruby
require 'csv'
require 'yaml'

record = {}

csv = CSV.parse(ARGF.read.encode(Encoding::UTF_8, Encoding::CP932)).to_a
csv.shift
total = csv.pop

namemap = YAML.load(File.read("namemap.yaml"))
namemap.default_proc = ->(h, k) { k }

csv.sort_by {|i| i[1] }.each do |i|
  record[sprintf("%s/%s-%s%s", i[1][5, 2], i[1][8, 2], namemap[i[2].tr("－", "ー").unicode_normalize(:nfkc).strip], (i[6].to_i == 1 ? "" : "(/#{i[6].to_i})"))] = i[5].to_i
end

YAML.dump({"out" => {"category" => record}}, STDOUT)
