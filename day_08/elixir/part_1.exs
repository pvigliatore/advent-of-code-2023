defmodule AdventOfCode.Day8.Solver do
  def solve(file) do
    [directions_input, _ | mapping_input] =
      file
      |> File.read!()
      |> String.split("\n")

    directions = parse_directions(directions_input)

    mapping =
      mapping_input
      |> Enum.flat_map(&parse_mapping/1)
      |> Map.new()

    directions
    |> Stream.transform("AAA", fn
      _direction, "ZZZ" -> {:halt, "ZZZ"}
      direction, location -> {[location], mapping["#{location}_#{direction}"]}
    end)
    |> Enum.count()
  end

  def parse_directions(directions) do
    directions
    |> String.graphemes()
    |> Stream.cycle()
  end

  def parse_mapping(input) do
    [_, id, left, right] = Regex.run(~r/([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)/, input)
    [{id <> "_L", left}, {id <> "_R", right}]
  end
end

AdventOfCode.Day8.Solver.solve("input")
|> IO.inspect()
