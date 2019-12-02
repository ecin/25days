#!/usr/bin/env ruby

require "minitest/autorun"
require "minitest/pride"

class Computer
  @@opcodes = {
    1 => proc { |a, b| a + b },
    2 => proc { |a, b| a * b },
  }

  class << self
    EXIT_CODE = 99

    def run(opcodes)
      opcodes = Array(opcodes)

      cursor = 0
      until opcodes[cursor] == EXIT_CODE
        opcodes = process_instruction(opcodes, cursor)
        cursor += 4
      end

      opcodes
    end

    private

    def process_instruction(opcodes, position = 0)
      instruction = @@opcodes[opcodes[position]]
      puts "Cursor: #{position}"
      puts "Code: #{opcodes[position]}"
      puts "Instruction: #{instruction}"
      puts "Opcodes: #{opcodes.inspect}"
      puts "A: #{opcodes[position+1]}"
      puts "B: #{opcodes[position+2]}"
      a_position = opcodes[position+1]
      b_position = opcodes[position+2]
      result = instruction.call(opcodes[a_position], opcodes[b_position])

      puts "Target position: #{opcodes[position+3]}"
      puts "Target result: #{result}"
      target = opcodes[position+3]
      opcodes[target] = result

      opcodes
    end
  end
end

describe "Opcodes" do

  it "runs instructions" do
    examples = [
      [[1,0,0,0,99], [2,0,0,0,99]],
      [[2,3,0,3,99], [2,3,0,6,99]],
      [[2,4,4,5,99,0], [2,4,4,5,99,9801]],
      [[1,1,1,4,99,5,6,0,99], [30,1,1,4,2,5,6,0,99]],
    ]

    examples.each do |(opcodes, result)|
      assert_equal result, Computer.run(opcodes)
    end
  end

end
