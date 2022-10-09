#!/bin/ruby

class CategoryClassifier
  def initialize map
    @map = []
    map.each do |category, patterns|
      patterns.each do |i|
        ptn = case
        when i[0] == "/" && i[-1] == "/"
          Regexp.new(i[1..-2])
        when i[0] == ">"
          StringIncluder.new(i[1..-1])
        else
          i
        end
        @map.push [ptn, category]
      end
    end
  end

  def [](key)
    index = @map.index {|i| i[0] === key}
    index && @map[index][1]
  end
end

class NameMapper
  def initialize map
    @map = []
    map.each do |i, name|
      ptn = case
      when i[0] == "/" && i[-1] == "/"
        i = Regexp.new(i[1..-2])
      when i[0] == ">"
        i = StringIncluder.new(i[1..-1])
      else
        i
      end
      @map.push [ptn, name]
    end
  end

  def [](key)
    index = @map.index {|i| i[0] === key}
    index ? @map[index][1] : key
  end
end

class StringIncluder < String
  def ===(str)
    str.include? self
  end
end

class Record < Hash
  def initialize
    super
    nm = (YAML.load(File.read("namemap.yaml")) rescue {})
    cm = (YAML.load(File.read("category.yaml")) rescue {})
    @namemap = NameMapper.new nm
    @category_map = CategoryClassifier.new cm
    self.default_proc = lambda {|h, k| h[k] = {} }
  end

  def checkout(date, name, cpart, value)
    name = @namemap[name.tr("－", "ー").unicode_normalize(:nfkc).strip]
    keys = [date, name]
    category = @category_map[name] || "unclassified"
    name += " (#{caprt})" if cpart
    key = keys.join("-")
    key += "_1" if self[category][key]
    key.succ! while self[category][key]
    self[category][key] = value
  end

  def finish
    hash = Hash.new
    self.each {|k, v| hash[k] = v }
    hash
  end
end