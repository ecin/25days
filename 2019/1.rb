#!/usr/bin/env ruby

require "minitest/autorun"
require "minitest/pride"

class FuelCalculator
  class << self
    def calculate(mass, include_fuel = false)
      if include_fuel
        fuel = fuel_for(mass)
        if fuel.zero?
          0
        else
          fuel + calculate(fuel, true)
        end
      else
        fuel_for(mass)
      end
    end

    private

    def fuel_for(mass)
      [(mass / 3.0).floor - 2, 0].max
    end
  end
end

describe "Fuel Counter-Upper" do
  it "counts fuel" do
    examples = [
      [12, 2],
      [14, 2],
      [1969, 654],
      [100756, 33583],
    ]

    examples.each do |(mass, fuel)|
      assert_equal fuel, FuelCalculator.calculate(mass)
    end
  end

  it "counts fuel recursively" do
    examples = [
      [14, 2],
      [1969, 966],
      [100756, 50346],
    ]

    examples.each do |(mass, fuel)|
      assert_equal fuel, FuelCalculator.calculate(mass, :include_fuel)
    end
  end
end
