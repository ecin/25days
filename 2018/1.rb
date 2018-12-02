require "minitest/autorun"
require "minitest/pride"

require "set"

def parse_frequency(input, separator = ",")
  input.split(separator).map(&:to_i).sum
end

def find_duplicate(input, separator = ",")
  frequency_changes = input.split(separator).map(&:to_i).cycle

  seen_frequencies = Set.new
  frequency_changes.inject(0) do |resulting_frequency, delta|
    if seen_frequencies.include?(resulting_frequency)
      return resulting_frequency
    else
      seen_frequencies << resulting_frequency
      resulting_frequency + delta
    end
  end
end

describe "Chronal Calibration" do
  it "returns the resulting frequency" do
    examples = [
      ["+1, -2, +3, +1", 3],
      ["+1, +1, +1", 3],
      ["+1, +1, -2", 0],
      ["-1, -2, -3", -6]
    ]

    examples.each do |frequency_changes, answer|
      assert_equal answer, parse_frequency(frequency_changes)
    end
  end

  it "can support an arbitrary separator" do
    frequency_changes = "17\n-1"
    assert_equal 16, parse_frequency(frequency_changes, "\n")
  end

  it "can find the first frequency that repeats twice" do
    examples = [
      ["+1, -1", 0],
      ["+3, +3, +4, -2, -4", 10],
      ["-6, +3, +8, +5, -6", 5],
      ["+7, +7, -2, -7, -4", 14]
    ]

    examples.each do |frequency_changes, answer|
      assert_equal answer, find_duplicate(frequency_changes)
    end
  end
end
