#!/usr/bin/ruby

require 'yaml'
require 'csv'
require_relative 'converter-utils'

csvstr = ARGF.read.encode(Encoding::UTF_8, Encoding::CP932).unicode_normalize(:nfkc)

csv = CSV.parse(csvstr).to_a

headerline = csv.shift
totalline = csv.pop
record = Record.new

csv.each do |i|
  date = i[0][5, 5]
  name = i[1]
  cpart = i[3].to_i == 1 ? nil : "(#{i[4]}/#{i[3]})"
  value = i[5].to_i

  record.checkout date, name, cpart, value
end

YAML.dump({"out" => record.finish}, STDOUT)
