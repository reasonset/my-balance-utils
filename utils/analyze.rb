#!/bin/ruby
require 'yaml'

class Analyze
  def initialize
    @sheets = ARGV.map do |i| 
      {
        file: i,
        data: YAML.load(File.read(i))
      }
    end
  end

  def run
    terms = {}
    @sheets.each do |i|
      mktotal
      i[:data]["out"].each_key do |k|
        terms[k] = true
      end
    end
    terms.each_key do |k|
      data = mkdata k
      plot k, data
    end
  end

  def plot term, data
    printf "\e[46m================== %s ==================\e[0m\n", term
    puts " TITLE |             GRAPH            | VALUE |RATE|TOTAL|BALANCE|DIFFAVG | DAR |"
    data[:tdata].each do |i|
      printf("%7s %s %7d %3s%% %4s%% %s %s %5s%%\e[0m\n", i[:name], mkbar(data[:min], data[:max], i[:subtotal]), i[:subtotal], rate_color(i[:rate]), total_color(@total[i[:sheet]]), balance_color(@balance[i[:sheet]]), diffavg_color(i[:diffavg]), dar_color(data[:subtotal_avg], i[:subtotal]))
    end
    puts
  end

  def mktotal
    @total = {}
    @balance = {}
    @sheets.each do |i|
      out_total = i[:data]["out"].sum(0) {|k, v| next 0 unless v;v.sum(0) {|k2, v2| v2} }
      @total[i[:file]] = out_total
      in_total = i[:data]["in"].sum(0) {|k, v| v || 0}
      @balance[i[:file]] = in_total - out_total
    end
    @total_avg = @total.sum(0) {|k, v| v } / @total.length
  end

  def mkdata term
    tdata = @sheets.map do |i|
      d = {
        sheet: i[:file],
        name: i[:file].delete("^0-9"),
        subtotal: (i[:data]["out"][term]&.sum(0) {|k, v| v} || 0),
        total: @total[i[:file]]
      }
      d[:rate] = d[:subtotal] / @total[i[:file]].to_f rescue 0
      d
    end
    # subtotal_avg = tdata.sum(0) {|i| i[:subtotal]} / tdata.reject {|i| i[:subtotal].zero? }.length
    subtotal_avg = tdata.sum(0) {|i| i[:subtotal]} / tdata.length
    tdata.each do |i|
      i[:diffavg] = i[:subtotal] - subtotal_avg
      i[:rate] = 0 if i[:rate].infinite?
      i[:rate] *= 100
    end
    {
      subtotal_avg: subtotal_avg,
      max: tdata.max_by {|i| i[:subtotal] }[:subtotal],
#      min: tdata.reject {|i| i[:subtotal].zero? }.min_by {|i| i[:subtotal] }[:subtotal],
      min: tdata.min_by {|i| i[:subtotal] }[:subtotal],
      tdata: tdata
    }
  end

  def mkbar min, max, value
    if value.zero?
      rate = 0
    else
      full_value = max - min
      this_value = value - min
      rate = full_value == this_value ? 30 : ((this_value / full_value.to_f) * 100 / 3.333).ceil
    end
    color = case rate
    when 0..5
      "\e[36m"
    when 6..10
      "\e[34m"
    when 11..15
      "\e[32m"
    when 16..20
      "\e[33m"
    when 21..25
      "\e[35m"
    else
      "\e[31m"
    end
    sprintf "%s%-30.30s\e[0m", color, ("|" * rate)
  end

  def rate_color rate
    color = case rate.to_i
    when 0..3
      "\e[36m"
    when 4..5
      "\e[34m"
    when 6..10
      "\e[32m"
    when 11..15
      "\e[33m"
    when 16..20
      "\e[35m"
    else
      "\e[31m"
    end
    sprintf "%s%3d\e[0m", color, rate
  end

  def total_color subtotal
    val = (subtotal / @total_avg.to_f * 100).to_i
    color = case val
    when 0..90
      "\e[36m"
    when 91..95
      "\e[34m"
    when 96..100
      "\e[32m"
    when 101..110
      "\e[33m"
    when 111..120
      "\e[35m"
    else
      "\e[31m"
    end
    sprintf "%s%4d\e[0m", color, val
  end

  def diffavg_color diffavg
    color = diffavg <= 0 ? "\e[36m" : "\e[35m"
    sprintf "%s%+8d\e[0m", color, diffavg
  end

  def dar_color subavg, subtotal
    rate = (subtotal.to_f / subavg * 100).to_i
    color = case rate
    when 0..30
      "\e[36m"
    when 31..50
      "\e[34m"
    when 51..100
      "\e[32m"
    when 101..150
      "\e[33m"
    when 151..200
      "\e[35m"
    else
      "\e[31m"
    end
    sprintf "%s%4d\e[0m", color, rate
  end

  def balance_color balance
    color = case balance
    when 60000..10000000
      "\e[36m"
    when 35000...60000
      "\e[34m"
    when 10000...35000
      "\e[32m"
    when -10000...10000
      "\e[33m"
    when -40000...-15000
      "\e[35m"
    else
      "\e[31m"
    end
    sprintf "%s%+7d\e[0m", color, balance
  end

end

g = Analyze.new

g.run