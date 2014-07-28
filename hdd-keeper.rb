#!/usr/bin/env ruby

require 'pry'

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

class HDDKeeper
  LeftTop     = {x: 1, y:2, z:0}
  LeftMiddle  = {x: 1, y:1, z:0}
  LeftBottom  = {x: 2, y:0, z:0}
  Length      = 3

  def self.reverse_x hash
    hash.clone.merge(x: -hash[:x])
  end

  def self.end_point hash
    hash.clone.merge(z: Length + hash[:z])
  end

  RightTop    = reverse_x(LeftTop)
  RightMiddle = reverse_x(LeftMiddle)
  RightBottom = reverse_x(LeftBottom)

  def self.begin_surface
    [
      [LeftBottom, LeftMiddle, LeftTop],
      [RightTop, RightMiddle, RightBottom],
      [RightBottom, RightMiddle, LeftMiddle],
      [LeftBottom, RightBottom, LeftMiddle]
    ]
  end

  def self.end_surface
    begin_surface.map do |pane|
      pane.reverse.map do |point|
        point.merge(z: point[:z] + Length)
      end
    end
  end

  def self.line_to_end_line line
    line.cycle(2).map.with_index(1){|p, i| i>2 ? end_point(p) : p}
  end


  def self.body_points
    [
      [RightBottom, LeftBottom],
      [RightTop, RightBottom],
      [RightMiddle, RightTop],
      [LeftBottom, LeftTop],
      [LeftTop, LeftMiddle],
      [LeftMiddle, RightMiddle]
    ].map{|l| line_to_end_line(l)}
  end

  def self.body
    self.body_points.map{|pane| pane.each_cons(3).to_a.map.with_index{|p,i| i.zero? ? p : p.reverse} }.flatten(1)
  end

end

STL.new file: 'hdd-keeper.stl' do

  HDDKeeper.begin_surface.each do |pane|
    face *pane
  end
  HDDKeeper.end_surface.each do |pane|
    face *pane
  end
  HDDKeeper.body.each do |pane|
    face *pane
  end
end
