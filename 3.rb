require "minitest/autorun"
require "minitest/pride"
require "decoratable/memoizable"

class Integer
  # Strategy:
  # This question boils down to finding the position of number
  # on the grid: the coordinates will be the number steps to reach it.

  def memory_steps
    position_on_grid.map(&:abs).sum
  end

  def position_on_grid
    return [0, 0] if self == 1

    spiral_range, depth = spiral_ranges.with_index.find do |range, _depth|
      range.include?(self)
    end

    directions = spiral_movement_enumerator(depth)
    position = [depth, -depth + 1]

    spiral_range.each.with_index do |value, index|
      if value == self
        return position
      else
        delta = directions.next
        position = [position[0] + delta[0], position[1] + delta[1]]
        next
      end
    end
  end

  def stress_chain
    Enumerator.new do |yielder|
      matrix = Hash.new { |hash, key| hash[key] = Hash.new { } }

      x = 0
      y = 0
      matrix[x][y] = 1

      yielder << matrix[x][y]
      depth = 0
      loop do
        directions = spiral_movement_enumerator(depth)

        directions.each do |delta_x, delta_y|
          x += delta_x
          y += delta_y

          matrix[x][y] = add_surrounding(matrix, x, y)
          yielder << matrix[x][y]
        end

        x += 1
        y += 0
        matrix[x][y] = add_surrounding(matrix, x, y)
        yielder << matrix[x][y]

        depth += 1
      end
    end
  end

  private

  # Generate one "turn" of the spiral at a time.
  #
  # Every turn is a range of numbers. We know the starting position
  # of every turn on the grid. From there, we can determine the position
  # of every number in said turn.
  #
  # WARNING: abuse of enumerators follows.
  def spiral_ranges
    Enumerator.new do |yielder|
      yielder << (1..1)

      start = 2
      range = 3

      loop do
        yielder << (start..(range**2))

        start = range**2 + 1
        range += 2
      end
    end
  end

  def add_surrounding(matrix, x, y)
    total = 0

    (-1..1).each do |delta_x|
      (-1..1).each do |delta_y|
        next if delta_x == 0 && delta_y == 0

        total += matrix[x + delta_x][y + delta_y].to_i
      end
    end

    total
  end

  # From the beginning of the turn, this enumerator tells us which direction
  # to move in to land on the next number.
  def spiral_movement_enumerator(depth)
    spiral_movement_enumerator_x(depth).zip(spiral_movement_enumerator_y(depth)).to_enum
  end

  def spiral_movement_enumerator_x(depth)
    return [] if depth.zero?

    side = depth * 2
    [[0] * (side - 1), [-1] * side, [0] * side, [1] * side].flatten.to_enum
  end

  def spiral_movement_enumerator_y(depth)
    return [] if depth.zero?

    side = depth * 2
    [[1] * (side - 1), [0] * side, [-1] * side, [0] * side].flatten.to_enum
  end
end

describe "Spiral Memory" do
  it "calculates the position of a number on the grid" do
    examples = [
      [1, [0, 0]],
      [12, [2,1]],
      [23, [0, -2]],
    ]

    examples.each do |input, output|
      assert_equal input.position_on_grid, output, "Expected position_on_grid(#{input}) to equal #{output}, got #{input.position_on_grid}"
    end
  end

  it "calculates the correct movements back to the first square" do
    examples = [
      [1, 0],
      [12, 3],
      [23, 2],
      [1024, 31],
    ]

    examples.each do |input, output|
      assert_equal input.memory_steps, output, "Expected memory_steps(#{input}) to equal #{output}, got #{input.memory_steps}"
    end
  end

  it "can perform a stress test" do
    examples = [
      [1, 1],
      [2, 1],
      [3, 2],
      [4, 4],
      [5, 5],
    ]

    examples.each do |input, output|
      assert_equal 1.stress_chain.take(input).last, output, "Expected stress_value(#{input}) to equal #{output}"
    end
  end
end

require "irb"
IRB.start
