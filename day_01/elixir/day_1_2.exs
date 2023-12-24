defmodule AdventOfCode.Day1Part2 do

  def run(file \\ "input") do
    file
    |> File.stream!()
    |> Stream.map(&parse_number/1)
    |> Enum.sum()
  end

  def parse_number(line) do
    tens_pattern = ~r/\d|one|two|three|four|five|six|seven|eight|nine/
    [tens] = Regex.run(tens_pattern, line, capture: :first)

    ones_pattern = ~r/.*(\d|one|two|three|four|five|six|seven|eight|nine)/
    [ones] = Regex.run(ones_pattern, line, capture: :all_but_first)

    (to_int(tens) * 10) + to_int(ones)
  end

  def to_int(digit) do
    case digit do
      "one" -> 1
      "two" -> 2
      "three" -> 3
      "four" -> 4
      "five" -> 5
      "six" -> 6
      "seven" -> 7
      "eight" -> 8
      "nine" -> 9
       numeric -> String.to_integer(numeric)
    end
  end
end
