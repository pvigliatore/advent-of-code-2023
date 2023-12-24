defmodule AdventOfCode.Day4.ScratchCard do
  defstruct [:id, :winning_numbers, :numbers]

  def score(scratch_card) do
    tabulate(scratch_card.winning_numbers, scratch_card.numbers, 0)
  end

  def tabulate(winning_numbers, numbers, score) when winning_numbers == [] or numbers == [] do
    if score == 0,
      do: 0,
      else: Integer.pow(2, score - 1)
  end

  def tabulate([first_winning | next_winning], [first_number | next_numbers], score) do
    cond do
      first_winning == first_number ->
        tabulate(next_winning, next_numbers, score + 1)

      first_winning < first_number ->
        tabulate(next_winning, [first_number | next_numbers], score)

      first_winning > first_number ->
        tabulate([first_winning | next_winning], next_numbers, score)

      true ->
        raise RuntimeError
    end
  end
end

defmodule AdventOfCode.Day4.Reader do
  def read(file \\ "input") do
    file
    |> File.stream!()
    |> Stream.map(&parse_scratch_card/1)
  end

  def parse_scratch_card(line) do
    [card_input, winning_number_input, number_input] = String.split(line, ~r/[|:]/)

    %AdventOfCode.Day4.ScratchCard{
      id: card_input |> String.slice(5..7) |> String.trim() |> String.to_integer(),
      winning_numbers: parse_numbers(winning_number_input),
      numbers: parse_numbers(number_input)
    }
  end

  def parse_numbers(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end
end

defmodule AdventOfCode.Day4.Solver do
  def solve(file) do
    file
    |> AdventOfCode.Day4.Reader.read()
    |> Stream.map(&AdventOfCode.Day4.ScratchCard.score/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end

AdventOfCode.Day4.Solver.solve("input")
