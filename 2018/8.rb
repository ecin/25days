require "minitest/autorun"
require "minitest/pride"

class Node
  attr_accessor :label, :children, :metadata

  def initialize(label)
    @label = label
    @children = []
    @metadata = []
  end

  def descendents
    descendent_helper(self)
  end

  def value
    if children.empty?
      metadata.sum
    else
      indexes = metadata.reject(&:zero?)
      indexes.map { |index| children[index - 1]&.value }.compact.sum
    end
  end

  private

  def descendent_helper(node)
    return node.children + node.children.flat_map { |child| descendent_helper(child) }
  end
end

class Tree
  include Enumerable

  class << self
    def from_input(input)
      tree = Tree.new
      current_node = tree.root
      stream = input.split(" ").map(&:to_i)

      parse_stream(stream, current_node, tree)
      tree
    end

    def parse_stream(stream, current_node, tree)
      if stream.empty?
        return
      else
        children_count, metadata_count = stream.shift(2)
        children_count.times do
          child = tree.create_node
          current_node.children << child
          parse_stream(stream, child, tree)
        end
        current_node.metadata.concat(stream.shift(metadata_count))
      end
    end
  end

  attr_reader :root

  def initialize
    @label_maker = :A
    @root = Node.new(next_label)
  end

  def each(&block)
    [@root].concat(@root.descendents).each(&block)
  end

  def create_node
    Node.new(next_label)
  end

  def value
    @root.value
  end

  private

  def next_label
    label = @label_maker
    @label_maker = @label_maker.next

    label
  end

end

describe " Memory Maneuver" do

end
