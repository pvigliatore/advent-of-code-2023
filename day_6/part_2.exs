defmodule AdventOfCode.Day6.Solver do
  defp read(file) do
    [time, distance] =
      file
      |> File.stream!()
      |> Enum.map(fn
        "Time: " <> values -> parse_number(values)
        "Distance: " <> values -> parse_number(values)
      end)

    {time, distance}
  end

  defp parse_number(line) do
    line
    |> String.replace(~r/\s+/, "")
    |> String.to_integer()
  end

  def solve(file) do
    file
    |> read()
    |> num_solutions()
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
