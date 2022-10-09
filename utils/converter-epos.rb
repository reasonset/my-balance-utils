#!/bin/ruby
require 'csv'
require 'yaml'
require_relative 'converter-utils'

record = Record.new

csv = CSV.parse(ARGF.read.encode(Encoding::UTF_8, Encoding::CP932)).to_a
csv.shift
total = csv.pop

csv.sort_by {|i| i[1] }.each do |i|
  date = sprintf "%s/%s", i[1][5, 2], i[1][8, 2]
  name = i[2]
  cpart = i[6].to_i == 1 ? nil : "/#{i[6].to_i}"
  value = i[5].to_i

  record.checkout date, name, cpart, value
end

YAML.dump({"out" => record.finish}, STDOUT)