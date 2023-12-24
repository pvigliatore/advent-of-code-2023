defmodule AdventOfCode.Day1 do
  @pattern ~r/^[a-z]*((?<only>\d)[a-z]*$|(?<first>\d).*(?<last>\d)[a-z]*$)/

  def parse_number(str) do
    %{"only" => only, "first" => tens, "last" => ones}  = Regex.named_captures(@pattern, str) 

    if only == "", 
      do: String.to_integer("#{tens}#{ones}"),
      else: String.to_integer("#{only}#{only}")
  end

  def part_1(file \\ "input") do
    file
    |> File.stream!()
    |> Stream.map(&parse_number/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end

AdventOfCode.Day1.part_1() |> IO.inspect(label: "Part 1")
