require "minitest/autorun"
require "minitest/pride"

class String
  def checksum(split_on = " ")
    row_differences = self.split("\n").map do |row|
      row_numbers = row.split(split_on).map(&:to_i)
      max = row_numbers.max
      min = row_numbers.min

      max - min
    end

    row_differences.sum
  end

  def checksum2(split_on = " ")
    self.split("\n").map do |row|
      row_numbers = row.split(split_on).map(&:to_i)
      pair = row_numbers.permutation(2).find { |(a, b)| Rational(a, b).denominator == 1 }

      pair[0] / pair[1]
    end.sum
  end
end

describe "Corruption Checksum" do
  it "calculates a checksum" do
    example = <<-SPREADSHEET
    5 1 9 5
    7 5 3
    2 4 6 8
    SPREADSHEET

    assert_equal 18, example.checksum
  end

  it "calculates a second checksum" do
    example = <<-SPREADSHEET
    5 9 2 8
    9 4 7 3
    3 8 6 5
    SPREADSHEET

    assert_equal 9, example.checksum2
  end
end
