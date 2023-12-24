defmodule AdventOfCode.Day8.Solver do
  def solve(file) do
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

    start_positions =
      mapping_input
      |> Stream.filter(&(&1 =~ ~r/..A.*/))
      |> Enum.map(&String.slice(&1, 0..2))
      |> IO.inspect(label: "STARTING POSITIONS")

    directions
    |> Stream.transform(start_positions, &traverse(&1, &2, mapping))
    |> Enum.count()
  end

  defp finished?(locations), do: Enum.all?(locations, &String.ends_with?(&1, "Z"))

  defp traverse(direction, current_locations, mappings) do
    if finished?(current_locations) do
      {:halt, current_locations}
    else
      next_locations =
        Enum.map(current_locations, &mappings["#{&1}_#{direction}"])
        |> IO.inspect()

      {[current_locations], next_locations}
    end
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

AdventOfCode.Day8.Solver.solve("input")
|> IO.inspect()
