require "minitest/autorun"
require "minitest/pride"

class Counter
  attr_reader :count

  def initialize(start = 0)
    @count = 0
  end

  def increase!
    @count += 1
  end
end

class Worker
  attr_reader :label, :step

  def initialize(label)
    @label = label
    @clock = 0
    @duration = 0
  end

  def duration_remaining(clock)
    (@clock + @duration) - clock
  end

  def work(step, duration, clock)
    @step = step
    @clock = clock
    @duration = duration
  end

  def done?(clock)
    clock >= @clock + @duration
  end

  def reset!
    @step = nil
    @clock = 0
    @duration = 0
  end

  def available?(clock)
    done?(clock)
  end
end

class Instructions
  class << self
    def from_input(input)
      instructions = self.new
      input.split("\n").each do |line|
        match = line.match(/Step (?<precursor>\w) must be finished before step (?<label>\w)/)
        instructions.add_step(match[:precursor], match[:label])
      end

      instructions
    end
  end

  attr_reader :steps

  def initialize()
    @steps = Hash.new { [] }
    @requirements = Hash.new { [] }
  end

  def add_step(precursor, label)
    @steps[precursor] <<= label
    @requirements[label] <<= precursor
    @requirements[precursor] = [] unless @requirements.key?(precursor)
  end

  def ordered_steps
    @steps.values.each { |value| value.sort! }
    current_step = root_steps.first
    queue = []

    handle_step(current_step, queue)

    queue
  end

  def complete_duration(worker_count, default_duration = 60)
    clock = 0
    counter = Counter.new
    workers = worker_count.times.map { Worker.new(counter.increase!) }

    queue = []
    hand_out_work(queue, workers, clock, default_duration)
  end

  def hand_out_work(queue, workers, clock, default_duration)
    while available_steps(queue).any?
      puts "Clock at #{clock}"
      available_workers = []

      workers.each do |worker|
        if worker.available?(clock)
          if !worker.step.nil?
            queue << worker.step
            puts "Worker #{worker.label} completed #{worker.step} at #{clock}"
          end
          worker.reset!
          available_workers << worker
        else
          puts "Worker #{worker.label} working on #{worker.step} for #{worker.duration_remaining(clock)}"
        end
      end

      steps = available_steps(queue)
      steps -= workers.select { |worker| !worker.available?(clock) }.map(&:step)
      steps = steps.take(available_workers.count)
      steps.each do |step|
        worker = available_workers.shift
        worker.work(step, duration(step, default_duration), clock)
        puts "Worker #{worker.label} working on #{worker.step} for #{worker.duration_remaining(clock)}"
      end

      clock += 1
    end

    clock - 1
  end

  def handle_step(step, queue)
    queue << step if @requirements[step].all? { |requirement| queue.include?(requirement) } && !queue.include?(step)
    available_steps(queue).each { |next_step| handle_step(next_step, queue) }
  end

  def available_steps(queue)
    @requirements.select { |step, requirements| requirements.all? { |requirement| queue.include?(requirement) } }.keys.sort - queue
  end

  def root_steps
    @steps.keys.select { |key| @steps.values.none? { |value| value.include?(key) } }
  end

  private

  def duration(label, default_duration = 0)
    @durations ||= ("A".."Z").to_a.zip((1..26).to_a).to_h
    @durations[label] + default_duration
  end
end

describe "The Sum of Its Parts" do
  before do
    @input = <<~INPUT
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
    INPUT

    @instructions = Instructions.from_input(@input)
  end

  it "can determine instruction order" do
    assert_equal ["A", "F"], @instructions.steps["C"]
    assert_equal ["B", "D"], @instructions.steps["A"]
    assert_equal ["E"], @instructions.steps["B"]
    assert_equal ["E"], @instructions.steps["D"]
    assert_equal ["E"], @instructions.steps["F"]
  end

  it "can find root steps" do
    assert_equal ["C"], @instructions.root_steps
  end

  it "can determine the correct order for all steps" do
    assert_equal %w(C A B D F E), @instructions.ordered_steps
  end

  it "can determine how much time is required to work through all steps" do
    assert_equal 15, @instructions.complete_duration(2, 0)
  end
end
