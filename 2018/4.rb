require "minitest/autorun"
require "minitest/pride"

require "time"
# 2:50 start
class SleepSchedule
  def self.parse(input)
    guards = {}
    input.split("\n").sort.each do |line|
      case line
      when /Guard/
        new_guard = Guard.new(line)
        @guard = guards[new_guard.id] ||= new_guard
      else
        @guard.parse_line(line)
      end
    end

    guards
  end

  class Guard
    attr_reader :id, :seconds_asleep, :per_minute_count

    def initialize(line)
      @id = line.match(/Guard #(?<id>[0-9]+)/)[:id].to_i
      @last_awake = parse_time(line)
      @seconds_asleep = []
      @per_minute_count = Hash.new { 0 }
    end

    def parse_line(line)
      time = parse_time(line)
      case line
      when /falls asleep/
        @last_asleep = time
      when /wakes up/
        @seconds_asleep << (time - @last_asleep).to_i
        (@last_asleep.min..time.min).each { |minute| @per_minute_count[minute] += 1 }
        @last_awake = time
      end
    end

    def minute_asleep_most
      @per_minute_count.max_by { |minute, count| count }[0]
    end

    def total_minutes_asleep
      minutes_asleep.sum
    end

    def minutes_asleep
      seconds_asleep.map { |seconds| seconds / 60 }
    end

    private

    def parse_time(line)
      match = line.match(/(?<time>[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+)/)
      Time.parse(match[:time])
    end
  end
end

describe "Repose Record" do
  before do
    input = <<~SCHEDULE
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-02 00:40] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-03 00:29] wakes up
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      [1518-11-05 00:45] falls asleep
      [1518-11-05 00:55] wakes up
    SCHEDULE

    @guards = SleepSchedule.parse(input)
  end

  it "can determine how many minutes each guard slept for" do
    guard_10 = @guards[10]
    guard_99 = @guards[99]

    assert_equal 50, guard_10.total_minutes_asleep
    assert_equal 30, guard_99.total_minutes_asleep
  end

  it "can determine which minute each guard slept for the most" do
    guard_10 = @guards[10]
    assert_equal 24, guard_10.minute_asleep_most
  end

  it "can determine which guard most consistently slept on a minute" do
    consistent_guard = @guards.max_by { |id, guard| guard.per_minute_count.max_by { |minute, count| count }[1] }[1]

    assert_equal 99, consistent_guard.id
    assert_equal 45, consistent_guard.per_minute_count.max_by { |minute, count| count }[0]
  end
end

if __FILE__ == $0
  require "irb"
  IRB.start
end
