defmodule AdventOfCode.Day8.Solver do
  def solve(file, start) do
    [directions_input, _ | mapping_input] =
      file
      |> File.read!()
      |> String.trim()
      |> String.split("\n")

    directions = parse_directions(directions_input)

    mapping =
      mapping_input
      |> Enum.flat_map(&parse_mapping/1)
      |> Map.new()

    directions
    |> Stream.transform(start, fn
      _direction, <<_::binary-size(2)>> <> "Z" -> {:halt, "_"}
      direction, location -> {[location], Map.fetch!(mapping, "#{location}_#{direction}")}
    end)
    |> Enum.count()
    |> IO.inspect(label: start)
  end

  def parse_directions(directions) do
    directions
    |> String.graphemes()
    |> Stream.cycle()
  end

  def parse_mapping(input) do
    [_, id, left, right] = Regex.run(~r/([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)/, input)
    [{id <> "_L", left}, {id <> "_R", right}]
  end
end

["QKA", "VMA", "AAA", "RKA", "LBA", "JMA"]
|> Enum.map(&AdventOfCode.Day8.Solver.solve("input", &1))

# Take the results of the above and compute the least common multiple.
# In this case the cycle from each start value to the first end values are:
# 12169 20093 20659 22357 13301 18961
#
# We assume that the path from the start value (__A) to the first terminal value (__Z) 
# is cyclical, that is once a terminal location is reached, continuing the traversal 
# loops through the same path as before.
#
# Least Common Multiple is 15,690,466,351,717
