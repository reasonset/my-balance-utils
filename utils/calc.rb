#!/usr/bin/ruby
# -*- mode: ruby; coding: UTF-8 -*-

require 'yaml'
require 'erb'

colors = %w:#C24E56 #6553C0 #74CDBF #89CD74 #F6894A #DA4DB7 #4D8DDA #E0DE52 #584272 #64D3D8 #AFEF7D #FD668C:

WIDTH_TOTAL_FACTOR = 0.001
WIDTH_ELEMENT_FACTOR = 0.003

TEMPLATE = <<EOF
<html>
  <head>
    <title>Balance Sheet</title>
    <style>
span {
  display: inline-block;
  margin: 0px;
  padding: 0px;
  border-width: 0px;
}
    </style>
  </head>
  <body>
    <h1>Summery</h1>
    <table>
      <caption>BALANCE</caption>
      <tbody>
        <tr><th>収入</th><td style="text-align:right;"><%= count[:intotal] %></td></tr>
        <tr><th>支出</th><td style="text-align:right;"><span style="color: #c03;"><%= count[:outtotal] %></span></td></tr>
        <tr><th></th><td style="text-align:right;"><span
<% if (count[:intotal] - count[:outtotal]) < 0 %>
  style="color: #c03;">▲
<% else %>
>
<% end %>
<%= count[:intotal] - count[:outtotal] %></span></td></tr>
      </tbody>
    </table>
    <%=  graph[:in] %>
<% graph[:in_keys].each_with_index do |k, index| %>
<div style="margin-top: 2px; margin-bottom: 2px;"><span style="width: 1em; hegiht: 1em; background-color: <%= colors[index % colors.length] %>">　</span><%= k %> (<%= sheet["in"][k] %>)</div>
<% end %>
    <%=  graph[:out] %>
<% graph[:out_keys].each_with_index do |k, index| %>
<div style="margin-top: 2px; margin-bottom: 2px;"><span style="width: 1em; hegiht: 1em; background-color: <%= colors[index % colors.length] %>">　</span><%= k %> (<%= (sheet["out"][k]&.values || [0]).sum %>) <%= "%.1f%%" % (((sheet["out"][k]&.values || [0]).sum) / OUT_TOTAL * 100) %></div>
<% end %>
    <div style="width: 300px; height: 300px; background: /*radial-gradient(#fff 30%, transparent 30%), */conic-gradient(<%= graph[:pie].join(",") %>); border-radius: 50%;"></div>

    <h1>Detail</h1>
<%
  nc = 0
  sheet["out"].each do |category, items|
    next unless items
%>
    <h2><%= category %></h2>
<%
  n = 0
  items.each do |k, v| %>
    <div><span style="<%= sprintf('background-color: %s; width: %d;', colors[n % colors.length], (v * WIDTH_ELEMENT_FACTOR)) %>">　</span><%= k %>(<%= v %>)</div>
<%
  n += 1
  end %>
  <div style="line-height: 1.8; vertical-align: middle; height: 2em; color: <%= colors[nc % colors.length] %>">TOTAL: <%= items.values.sum %></div>
<%
  nc += 1
  end %>
    <h1>Memo</h1>
    <ul>
<% sheet["memo"].each do |i| %>
      <li><%= i %></li>
<% end %>
    </ul>
  </body>
</html>
EOF

unless ARGV.size == 1 && ARGV[0] =~ /^\d{6}$/
  abort "calc.rb YYYYMM"
end

sheet_name = ARGV.shift
sheet = YAML.load(File.read("sheet/sheet-#{sheet_name}.yaml"))

count = {}

count[:intotal] = sheet["in"].values.sum
count[:outtotal] = sheet["out"].map {|k, v| v&.values || 0}.flatten.sum

graph = {}
keys = sheet["in"].keys
graph[:in_keys] = keys
graph[:in] = keys.each_with_index.map {|i, index| sprintf('<span style="background-color: %s; width: %d; height:1em;"></span>', colors[index % colors.length], sheet["in"][i] * WIDTH_TOTAL_FACTOR) }.join
graph[:out] = {}

categories = sheet["out"].keys
graph[:out_keys] = categories
graph[:out] = categories.each_with_index.map {|i, index| sprintf('<span style="background-color: %s; width: %d; height:1em;"></span>', colors[index % colors.length], (sheet["out"][i]&.values || [0]).sum * WIDTH_TOTAL_FACTOR) }.join

OUT_TOTAL = categories.map {|i| (sheet["out"][i]&.values || [0]).sum }.sum.to_f

last_in = 0
graph[:pie] = categories.each_with_index.sort_by {|i, index| (sheet["out"][i]&.values || [0]).sum }.reverse.map {|i, index|
  before = last_in
  last_in = last_in + (sheet["out"][i]&.values || [0]).sum / OUT_TOTAL * 100
  last_in = 100 if last_in > 100
  sprintf('%s %.2f%% %.2f%%', colors[index % colors.length], before, last_in)
}

File.open("rendered/sheet-#{sheet_name}.html", "w") do |f|
  f.puts ERB.new(TEMPLATE).result(binding)
end