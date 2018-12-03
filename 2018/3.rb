require "minitest/autorun"
require "minitest/pride"

class Claim
  def self.parse(string)
    matches = string.match(/#(?<number>[0-9]+) @ (?<left>[0-9]+),(?<top>[0-9]+): (?<width>[0-9]+)x(?<height>[0-9]+)/)
    self.new(
      number: matches[:number].to_i,
      left: matches[:left].to_i,
      top: matches[:top].to_i,
      width: matches[:width].to_i,
      height: matches[:height].to_i
    )
  end

  def self.empty_claim
    self.new(
      number: 0,
      left: 0,
      top: 0,
      width: 0,
      height: 0
    )
  end

  def self.overlap_amount(claims)
    overlapping_claims = claims.combination(2).map { |(claim1, claim2)| claim1.overlapping_claim(claim2) }
    total_overlap_area = overlapping_claims.map(&:area).sum

    duplicate_overlap = overlapping_claims.combination(2).map { |(claim1, claim2)| claim1.overlapping_claim(claim2) }
    duplicate_overlap_area = duplicate_overlap.map(&:area).sum

    total_overlap_area - duplicate_overlap_area
  end

  def self.overlap_amount2(claims)
    grid = Hash.new { 0 }

    claims.each { |claim| claim.cells.each { |cell| grid[cell] += 1 } }
    grid.count { |cell, value| value > 1 }
  end

  def self.non_overlapping_claim(claims)
    claims.find do |claim|
      remaining_claims = claims - [claim]
      remaining_claims.none? { |other_claim| claim.overlap?(other_claim) }
    end
  end

  attr_accessor :number, :left, :top, :width, :height

  def initialize(number:, left:, top:, width:, height:)
    @number = number
    @left = left
    @top = top
    @width = width
    @height = height
  end

  def area
    width * height
  end

  def cells
    (left...left+width).to_a.product((top...top+height).to_a)
  end

  def overlap?(other_claim)
    vertical_overlap?(other_claim) && horizontal_overlap?(other_claim)
  end

  def overlap_amount(other_claim)
    if overlap?(other_claim)
      (top - other_claim.top).abs + (left - other_claim.left).abs
    else
      0
    end
  end

  def overlapping_claim(other_claim)
    overlapping_claim = Claim.empty_claim

    if overlap?(other_claim)
      overlapping_claim.left = left < other_claim.left ? other_claim.left : left
      overlapping_claim.width = [right, other_claim.right].min - overlapping_claim.left

      overlapping_claim.top = top < other_claim.top ? other_claim.top : top
      overlapping_claim.height = [bottom, other_claim.bottom].min - overlapping_claim.top
    end

    overlapping_claim
  end

  protected

  def vertical_overlap?(other_claim)
    (top <= other_claim.top && bottom >= other_claim.top) || (top >= other_claim.top && top <= other_claim.bottom)
  end

  def horizontal_overlap?(other_claim)
    (left <= other_claim.left && right >= other_claim.left) || (left >= other_claim.left && left <= other_claim.right)
  end

  def bottom
    top + height
  end

  def right
    left + width
  end
end

describe "No Matter How You Slice It" do
  it "can parse a claim" do
    claim = Claim.parse("#123 @ 3,2: 5x4")
    assert_equal 123, claim.number
    assert_equal 3, claim.left
    assert_equal 2, claim.top
    assert_equal 5, claim.width
    assert_equal 4, claim.height
  end

  describe "overlapping" do
    before do
      @claim1 = Claim.parse("#1 @ 1,3: 4x4")
      @claim2 = Claim.parse("#2 @ 3,1: 4x4")
      @claim3 = Claim.parse("#3 @ 5,5: 2x2")
    end
    it "can determine if two claims overlap" do
      assert @claim1.overlap?(@claim2)
      assert @claim2.overlap?(@claim1)
      assert !@claim1.overlap?(@claim3)
      assert !@claim2.overlap?(@claim3)
    end

    it "can determine the amount of overlap between two claims" do
      assert_equal 0, @claim1.overlap_amount(@claim3)
      assert_equal 4, @claim1.overlap_amount(@claim2)
      assert_equal 4, @claim2.overlap_amount(@claim1)
      assert_equal 0, @claim3.overlap_amount(@claim2)
    end

    it "can generate an overlapping claim" do
      overlapping_claim = @claim1.overlapping_claim(@claim2)
      assert_equal 4, overlapping_claim.area
      assert_equal 3, overlapping_claim.top
      assert_equal 3, overlapping_claim.left
    end

    it "can determine the total overlap for a group of claims" do
      assert_equal 4, Claim.overlap_amount([@claim1, @claim2, @claim3])
    end

    it "can determine the total overlap for a group of claims, faster" do
      assert_equal 4, Claim.overlap_amount2([@claim1, @claim2, @claim3])
    end

    it "can find a non-overlapping claim" do
      assert_equal @claim3, Claim.non_overlapping_claim([@claim1, @claim2, @claim3])
    end
  end
end

if __FILE__ == $0
  require "irb"
  IRB.start
end
