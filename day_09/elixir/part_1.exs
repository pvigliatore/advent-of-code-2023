defmodule AdventOfCode.Day9 do
  def solve(file \\ "input") do
    file
    |> read()
    |> Stream.map(&extrapolate/1)
    |> Enum.sum()
  end

  def read(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_history/1)
  end

  defp parse_history(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Unfold the history in pairs
  """
  def extrapolate(history, nums \\ []) do
    first_historical = hd(history)

    if Enum.all?(history, &(&1 == 0)) do
      Enum.reduce(nums, &(&1 - &2))
    else
      history
      |> diffs()
      |> extrapolate([first_historical | nums])
    end
  end

  def pairs(history) do
    Stream.unfold(history, fn
      [_last] -> nil
      [first, second | rest] -> {{first, second}, [second | rest]}
    end)
  end

  def diffs(history) do
    history
    |> pairs()
    |> Enum.map(fn {first, second} -> second - first end)
  end
end

AdventOfCode.Day9.solve()
|> IO.inspect()
