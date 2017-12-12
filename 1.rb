require "minitest/autorun"
require "minitest/pride"

class Integer
  def captcha
    circular_list.each_cons(2).inject(0) do |total, (first, second)|
      first == second ? total += first : total
    end
  end

  def captcha2
    delta = self.to_s.length / 2
    circular_list2.each_cons(delta + 1).inject(0) do |total, numbers|
      numbers.first == numbers.last ? total += numbers.first : total
    end
  end

  private

  def circular_list
    list = self.to_s.split("").map(&:to_i)
    list + [list.first]
  end

  def circular_list2
    list = self.to_s.split("").map(&:to_i)
    list + list[0..list.length/2 - 1]
  end
end


describe "Inverse Captcha" do
  it "calculates the correct captcha" do
    examples = [
      [1122, 3],
      [1111, 4],
      [1234, 0],
      [91212129, 9],
    ]

    examples.each do |input, output|
      assert_equal input.captcha, output, "Expected captcha(#{input}) to equal #{output}, got #{input.captcha}"
    end
  end

  it "calculates the correct second captcha" do
    examples = [
      [1212, 6],
      [1221, 0],
      [123425, 4],
      [123123, 12],
      [12131415, 4],
    ]

    examples.each do |input, output|
      assert_equal input.captcha2, output, "Expected captcha(#{input}) to equal #{output}, got #{input.captcha2}"
    end
  end
end
