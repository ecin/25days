require "minitest/autorun"
require "minitest/pride"

Infinity = 1/0.0

class Surrounding
  class << self
    include Enumerable
    def each(&block)
      Enumerator.new do |yielder|
        (0..Infinity).each do |distance|
          yielder << (-distance..distance).to_a.product((-distance..distance).to_a).select do |(x, y)|
            (x.abs + y.abs) == distance
          end
        end
      end
    end
  end
end

class Map
  def initialize(coordinates, boundaries)
    # coordinates hash, with [x, y] as the key
    @coordinates = coordinates
    @boundaries = boundaries
  end

  def closest_to(x, y)
    found = []
    Surrounding.each.with_index do |deltas, index|
      deltas.each do |(delta_x, delta_y)|
        ping = @coordinates[[delta_x + x, delta_y + y]]
        found << ping if ping
      end

      return found.uniq if found.any?
    end
  end

  def closest_to2(x, y)
    current = Coordinate.new(x, y)
    min_distance = @coordinates.map { |_, coordinate| current - coordinate }.min
    @coordinates.values.select { |coordinate| current - coordinate == min_distance }
  end

  def process_points!
    result = Hash.new { 0 }
    (@boundaries[:west]..@boundaries[:east]).each do |x|
      (@boundaries[:north]..@boundaries[:south]).each do |y|
        closest = closest_to2(x, y)
        if closest.size == 1
          puts "closest_to(#{x},#{y}) is #{closest.first.inspect}"
          result[closest.first.label] += 1
        else
          next
        end
      end
    end

    result
  end

  def find_safe_area(total_distance_max)
    safe_cells = 0
    (@boundaries[:west]..@boundaries[:east]).each do |x|
      (@boundaries[:north]..@boundaries[:south]).each do |y|
        safe_cells += 1 if total_distance_for(x, y) < total_distance_max
      end
    end

    safe_cells
  end

  def total_distance_for(x, y)
    current = Coordinate.new(x, y)
    @coordinates.map { |_, coordinate| current - coordinate }.sum
  end
end

class Coordinate
  class << self
    def parse(line)
      match = line.match(/(?<x>[0-9]+), (?<y>[0-9]+)/)
      self.new(match[:x].to_i, match[:y].to_i)
    end

    def from_input(input)
      input.split("\n").map { |line| self.parse(line) }
    end

    def calculate_areas(coordinates)
      label = :A
      labelled_coordinates = coordinates.each { |coordinate| coordinate.label = label; label = label.next }

      starting_coordinate = coordinates.first
      boundaries = {
        north: starting_coordinate.y,
        south: starting_coordinate.y,
        west: starting_coordinate.x,
        east: starting_coordinate.x
      }

      indexed_coordinates = {}

      labelled_coordinates.each do |coordinate, label|
        indexed_coordinates[[coordinate.x, coordinate.y]] = coordinate

        # Could also calculate these with max_by and min_by after the fact.
        boundaries[:north] = coordinate.y if coordinate.y < boundaries[:north]
        boundaries[:south] = coordinate.y if coordinate.y > boundaries[:south]
        boundaries[:west]  = coordinate.x if coordinate.x < boundaries[:west]
        boundaries[:east]  = coordinate.x if coordinate.x > boundaries[:east]
      end

      # Mark infinite coordinates
      labelled_coordinates.each do |coordinate, label|
        coordinate.infinite = infinite_coordinate?(coordinate, boundaries)
      end

      map = Map.new(indexed_coordinates, boundaries)
      #map.process_points!
      map.find_safe_area(10000)
    end

    private

    def infinite_coordinate?(coordinate, boundaries)
      coordinate.x == boundaries[:west] ||
        coordinate.x == boundaries[:east] ||
        coordinate.y == boundaries[:north] ||
        coordinate.y == boundaries[:south]
    end
  end

  attr_reader :x, :y
  attr_accessor :infinite, :label

  def initialize(x, y, label = nil)
    @x = x
    @y = y
    @infinite = false
    @label = label
  end

  def ==(other_coordinate)
    @x == other_coordinate.x && @y == other_coordinate.y
  end

  def infinite?
    @infinite
  end

  def -(other_coordinate)
    (self.x - other_coordinate.x).abs + (self.y - other_coordinate.y).abs
  end

  def south?(coordinate)
    self.y < coordinate.y
  end

  def north?(coordinates)
    self.y > coordinate.y
  end

  def west?(coordinate)
    self.x < coordinate.x
  end

  def east?(coordinate)
    self.x > coordinate.x
  end
end

describe "Chronal Coordinates" do
  before do
    @input = <<~INPUT
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
    INPUT
    @coordinates = Coordinate.from_input(@input)
  end

  it "parses correctly" do
    assert_equal 6, @coordinates.length

    first_coordinate = @coordinates.first
    assert_equal 1, first_coordinate.x
    assert_equal 1, first_coordinate.y

    last_coordinate = @coordinates.last
    assert_equal 8, last_coordinate.x
    assert_equal 9, last_coordinate.y
  end

  it "can determine the Manhattan distance between two coordinates" do
    assert_equal 0, Coordinate.new(1, 1) - Coordinate.new(1, 1)
    assert_equal 2, Coordinate.new(0, 0) - Coordinate.new(1, 1)
  end

  it "can find closest coordinates to any arbitrary point on the map" do
    coordinates = @coordinates.inject({}) do |indexed, coordinate|
      indexed[[coordinate.x, coordinate.y]] = coordinate
      indexed
    end
    map = Map.new(coordinates)

    assert_equal [Coordinate.new(1, 1)], map.closest_to(1, 1)
    assert_equal [Coordinate.new(1, 1)], map.closest_to(2, 2)
  end

  it "can find the area of a particular coordinate" do
    areas = Coordinate.calculate_areas(@coordinates)

    assert_equal Infinity, areas[:A]
    assert_equal Infinity, areas[:B]
    assert_equal Infinity, areas[:C]
    assert_equal 9, areas[:D]
    assert_equal 17, areas[:E]
    assert_equal Infinity, areas[:F]
  end

end
