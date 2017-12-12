require "minitest/autorun"
require "minitest/pride"
require "set"
class String
  def valid_passphrase?
    seen = Hash.new { false }
    self.split(" ").all? do |word|
      if seen[word]
        next false
      else
        seen[word] = true
      end
    end
  end

  def valid_passphrase2?
    seen = Hash.new { false }
    self.split(" ").all? do |word|
      permutations = word.each_char.to_a.permutation(word.length)
      key = Set.new(permutations)
      if seen[key]
        next false
      else
        seen[key] = true
      end
    end
  end
end

describe "High-Entropy Passphrases" do
  it "determines if a passphrase is valid" do
    examples = [
      ["aa bb cc dd ee", true],
      ["aa bb cc dd aa", false],
      ["aa bb cc dd aaa", true],
    ]

    examples.each do |(input, output)|
      assert_equal output, input.valid_passphrase?
    end
  end

  it "determines if a passphrase is valid, anagram-style" do
    examples = [
      ["abcde fghij", true],
      ["abcde xyz ecdab", false],
      ["a ab abc abd abf abj", true],
      ["iiii oiii ooii oooi oooo", true],
      ["oiii ioii iioi iiio", false],
    ]

    examples.each do |(input, output)|
      assert_equal output, input.valid_passphrase2?, "Expected valid_passphrase2?(#{input}) to equal #{output}"
    end
  end
end
