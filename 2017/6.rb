require "minitest/autorun"
require "minitest/pride"

class Enumerator
  def with_modulo_index(modulo = 1)
    Enumerator.new do |yielder|
      self.each.with_index do |n, i|
        yielder << [n, i % modulo]
      end
    end
  end
end

class Array
  def reallocate!
    reallocations.count
  end

  private

  def reallocations
    Enumerator.new do |yielder|
      seen = Hash.new { false }
      continue = true
      cycle = 0

      loop do
        # Here we iterate over the array several times to find the max
        # and it's index. However, after the first iteration, we should
        # be able to keep track of which index has the most blocks at all
        # times. Whatevs, this works though!
        blocks = self.max
        emptied_index = self.find_index { |n| n == blocks }

        # We've seen our current state, of course.
        seen[self] = cycle

        # Clear out the blocks we're about to distribute.
        self[emptied_index] = 0

        # At this point I'm overcomplicating things for the heck of it.
        ring = self.cycle.with_modulo_index(self.length)

        # Let's move the cursor to the block we've cleared out
        (emptied_index + 1).times { ring.next }

        # Let a redistribution cycle begin!
        blocks.times do
          current_blocks, index = ring.next
          self[index] = current_blocks + 1
        end

        # Yield our newly redistributed self
        yielder << self

        cycle += 1

        if seen[self]
          # Got lazy, so let's just print out the result to the second
          # part of the daily challenge.
          puts cycle - seen[self]
          break
        end
      end
    end
  end
end

describe "Memory Reallocation" do
  it "reallocates memory until this many steps" do
    examples = [
      [[0,2,7,0], 5],
    ]

    examples.each do |input, output|
      assert_equal output, input.reallocate!
    end
  end
end
