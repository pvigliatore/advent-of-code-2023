defmodule AdventOfCode.Day6.Solver do
  defp read(file) do
    file
    |> File.stream!()
    |> Stream.map(fn
      "Time: " <> values -> values
      "Distance: " <> values -> values
    end)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ~r/ +/))
    |> Stream.map(&parse_integers/1)
    |> Enum.zip()
  end

  defp parse_integers(nums), do: Enum.map(nums, &String.to_integer/1)

  def solve(file) do
    file
    |> read()
    |> Stream.map(&num_solutions/1)
    |> Enum.product()
  end

  defp num_solutions({time, record}) do
    1..time
    |> Stream.filter(&winner?(&1, time, record))
    |> Enum.count()
  end

  defp winner?(charge, time, record) do
    charge * (time - charge) > record
  end
end

AdventOfCode.Day6.Solver.solve("input")
|> IO.inspect()
