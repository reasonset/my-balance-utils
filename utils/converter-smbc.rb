#!/usr/bin/ruby

require 'yaml'
require 'csv'

csvstr = ARGF.read.encode(Encoding::UTF_8, Encoding::CP932).unicode_normalize(:nfkc)

csv = CSV.parse(csvstr).to_a

headerline = csv.shift
totalline = csv.pop

namemap = YAML.load(File.read("namemap.yaml"))

namemap.default_proc = ->(h, k) {
  k
}

record = {}

csv.each do |i|
  key = sprintf('%s-%s%s', i[0][5, 5], namemap[i[1]], (i[3].to_i == 1 ? "" : "(#{i[4]}/#{i[3]})") )
  if record[key]
    postfix = "_1"
    postfix.succ! while record[key + postfix]
    key = key + postfix
  end
  record[key] = i[5].to_i
end

YAML.dump({"out" => {"category" => record}}, STDOUT)
