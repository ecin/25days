require "minitest/autorun"
require "minitest/pride"

class String
  def reduce!
    copy = self.dup
    changed = true
    while changed
      changed = false
      pairs = copy.each_char.each_cons(2).to_a
      result = ""

      until pairs.empty?
        pair = pairs.shift
        if reactive?(*pair)
          changed = true
          if pairs.size == 1
            result += pairs.last[1]
          end
          pairs.shift
        else
          result += pair[0]
          if pairs.empty?
            result += pair[1]
          end
        end
      end

      copy = result
    end

    copy
  end

  def reduce2!
    copy = self.dup
    copy.each_char.inject("") do |result, char|
      if reactive?(result[-1], char)
        result = result[0..-2]
      else
        result += char
      end
    end
  end

  def maximally_reduce!
    ("a".."z").map do |polymer|
      copy = self.dup.gsub(/#{polymer}/i, "")
      copy.reduce2!
    end.min_by(&:length)
  end

  private

  def reactive?(char1, char2)
    if char1.nil? || char2.nil?
      false
    else
      char1 != char2 && (char1 == char2.upcase || char1.upcase == char2)
    end
  end
end
describe "Alchemical Reduction" do
  it "reduces the polymer" do
    examples = [
      ["aA", ""],
      ["abBA", ""],
      ["abAB", "abAB"],
      ["aabAAB", "aabAAB"],
      ["dabAcCaCBAcCcaDA", "dabCBAcaDA"]
    ]

    examples.each do |(input, answer)|
      assert_equal answer, input.reduce!, "expected '#{input}' to reduce to '#{answer}'"
      assert_equal answer, input.reduce2!, "expected '#{input}' to reduce to '#{answer}'"
    end
  end

  it "can maximally reduce" do
    assert_equal "daDA", "dabAcCaCBAcCcaDA".maximally_reduce!
  end

end

if __FILE__ == $0
  require "irb"
  #IRB.start
end
