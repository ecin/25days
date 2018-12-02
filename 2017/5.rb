require "minitest/autorun"
require "minitest/pride"

class Array
  def escape_steps
   copy = self.dup
   cursor = 0

   steps = 0
   until cursor >= copy.length || cursor < 0
    copy[cursor] += 1
    cursor += copy[cursor] - 1
    steps += 1
   end

   steps
  end

  def escape_steps2
   copy = self.dup
   cursor = 0

   steps = 0
   until cursor >= copy.length || cursor < 0
    offset = copy[cursor]
    delta = offset >= 3 ? -1 : 1
    copy[cursor] += delta
    cursor += copy[cursor] - delta
    steps += 1
   end

   steps
  end
end

describe "Twisty Trampolines" do
  it "counts the steps to escape" do
    examples = [
      [[0, 3, 0, 1, -3], 5],
    ]

    examples.each do |input, output|
      assert_equal output, input.escape_steps
    end
  end

  it "counts the steps to escape via a new set of rules" do
    examples = [
      [[0, 3, 0, 1, -3], 10],
    ]

    examples.each do |input, output|
      assert_equal output, input.escape_steps2
    end
  end
end
