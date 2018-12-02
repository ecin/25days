require "minitest/autorun"
require "minitest/pride"

class String
  def counts
    seen = Hash.new { 0 }
    self.each_char do |char|
      seen[char] += 1
    end

    [seen.any? { |_, count| count == 2 } ? 1 : 0, seen.any? { |_, count| count == 3 } ? 1 : 0]
  end
end

def checksum(input, separator = "\n")
  values = input.split(separator).map(&:counts).reduce([0, 0]) do |(doubles, triples), (double, triple)|
    [doubles + double, triples + triple]
  end
  values[0] * values[1]
end

def find_similar(boxes)
  # find pairs that have one character diff
  box1, box2 = boxes.combination(2).find do |(box1, box2)|
    count = box1.split("").zip(box2.split("")).count { |(a, b)| a != b }
    count == 1
  end

  # Remove errant character.
  answer = ""
  box1.split("").each_with_index do |char, index|
    answer += char if char == box2[index]
  end

  answer
end

def find_similar_hashes(boxes)
  hashes = Hash.new { 0 }

  boxes.each do |box|
    chars = box.chars
    chars.each_with_index do |_, index|
      if index == 0
        key = chars[1..-1]
      elsif index == chars.size - 1
        key = chars[0..-2]
      else
        key = chars[0..index - 1] + chars[index + 1..-1]
      end
      hashes[key] += 1

      return key.join if hashes[key] == 2
    end
  end
end

describe "Inventory Management System" do
  it "can generate a checksum" do
    examples = [
      ["abcdef", [0, 0]],
      ["bababc", [1, 1]],
      ["abbcde", [1, 0]],
      ["abcccd", [0, 1]],
      ["aabcdd", [1, 0]],
      ["abcdee", [1, 0]],
      ["ababab", [0, 1]]
    ]

    examples.each do |string, answer|
      assert_equal answer, string.counts
    end

    input = examples.map(&:first).join("\n")
    assert_equal 12, checksum(input)
  end

  it "can find the similar ids" do
    examples = [
      [%w(abcde fghij klmno pqrst fguij axcye wvxyz), "fgij"]
    ]

    examples.each do |example, answer|
      assert_equal answer, find_similar(example)
      assert_equal answer, find_similar_hashes(example)
    end
  end
end
