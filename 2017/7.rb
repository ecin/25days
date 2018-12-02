require "minitest/autorun"
require "minitest/pride"

require "ostruct"

class String
  def parse
    match = self.match /(?<process>\w+)\s+\((?<weight>\d+)\)(\s+)?(-> (?<subprocesses>((\w+)(, )?)+))?/
    OpenStruct.new(
      name: match[:process],
      weight: match[:weight].to_i,
      subprocesses: (match[:subprocesses] || "").split(", ")
    )
  end
end

class Tower
  class << self
    def parse(tree)
      processes = tree.split("\n").map(&:parse)
      Tower.new(processes)
    end
  end

  def initialize(processes)
    @tree = {}
    @parents = {}
    processes.each do |process|
      @tree[process.name] = process.subprocesses

      process.subprocesses.each do |subprocess|
        @parents[subprocess] = process.name
      end
    end
  end

  def root
    # Start at any node and follow the parents until the last one.
    process, _ = @tree.first

    loop do
      parent = @parents[process]

      if parent.nil?
        return process
      else
        process = parent
      end
    end
  end

  private

  def weight(process)

  end
end

describe "Recursive Circue" do
  let(:tree) do
    <<~TREE
    pbga (66)
    xhth (57)
    ebii (61)
    havc (66)
    ktlj (57)
    fwft (72) -> ktlj, cntj, xhth
    qoyq (66)
    padx (45) -> pbga, havc, qoyq
    tknk (41) -> ugml, padx, fwft
    jptl (61)
    ugml (68) -> gyxo, ebii, jptl
    gyxo (61)
    cntj (57)
    TREE
  end
  let(:tower) { Tower.parse(tree) }

  it "parses a single process description" do
    description = "fwft (72) -> ktlj, cntj, xhth"

    examples = [
      ["fwft (72) -> ktlj, cntj, xhth", ["fwft", 72, %w(ktlj cntj xhth)]],
      ["ebii (61)", ["ebii", 61, %w()]],
    ]

    examples.each do |description, (name, weight, subprocesses)|
      process = description.parse
      assert_equal name, process.name
      assert_equal weight, process.weight
      assert_equal subprocesses, process.subprocesses
    end
  end

  it "finds the root of a tree" do
    assert_equal "tknk", tower.root
  end

  it "finds the unbalanced process" do
    unbalanced_process, ideal_weight = tower.find_unbalanced_process
    assert_equal "tknk", unbalanced_process.name
    assert_equal 60, ideal_weight
  end
end
