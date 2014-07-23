#!/usr/bin/env ruby

class STL
  def initialize options={}, &block
    @buffer = []
    name = options[:name] || 'object'
    stlputs "solid #{name}"
    begin
      instance_eval &block
    ensure
      stlputs "endsolid #{name}"
    end
    if options && options[:io]
      options[:io].write data
    elsif options && options[:file]
      File.open(options[:file],'w'){|f|f.write data}
    end
  end

  def data
    @buffer.join "\n"
  end

  private

  def stlputs str
    @buffer << str
  end

  def face p1,p2,p3,flip=false
    p2,p3=p3,p2 if flip
    stlputs "facet normal 0 0 0"
    stlputs "outer loop"
    [p1,p2,p3].each do |p|
      stlputs "vertex #{p[:x].round 4} #{p[:y].round 4} #{p[:z].round 4}"
    end
    stlputs "endloop"
    stlputs "endfacet"
  end

end
