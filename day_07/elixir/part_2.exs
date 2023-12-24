defmodule AdventOfCode.Day7.Hand do
  defstruct [:cards, :type]

  def new(input) do
    cards = String.graphemes(input)

    %__MODULE__{
      cards: cards,
      type: type(cards)
    }
  end

  defp type(cards) do
    joker_count = Enum.count(cards, &(&1 == "J"))

    card_count =
      cards
      |> Enum.frequencies()
      |> Map.drop(["J"])
      |> Map.values()
      |> Enum.sort(:desc)
      |> then(fn
        [] -> [5]
        [most_repeated | rest] -> [most_repeated + joker_count | rest]
      end)

    case card_count do
      [5] -> 6
      [4, 1] -> 5
      [3, 2] -> 4
      [3, 1, 1] -> 3
      [2, 2, 1] -> 2
      [2, 1, 1, 1] -> 1
      [1, 1, 1, 1, 1] -> 0
    end
  end

  defp card_strength(card) do
    case card do
      "J" -> -1
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "T" -> 10
      n -> String.to_integer(n)
    end
  end

  def compare(left, right) do
    case signum(left.type - right.type) do
      -1 ->
        :lt

      0 ->
        left_hand_strength = Enum.map(left.cards, &card_strength/1)
        right_hand_strength = Enum.map(right.cards, &card_strength/1)
        if left_hand_strength <= right_hand_strength, do: :lt, else: :gt

      1 ->
        :gt
    end
  end

  defp signum(n) do
    cond do
      n < 0 -> -1
      n == 0 -> 0
      n > 0 -> 1
    end
  end
end

defmodule AdventOfCode.Day7.Solver do
  alias AdventOfCode.Day7.Hand

  def solve(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [hand, bid] -> {Hand.new(hand), String.to_integer(bid)} end)
    |> Enum.sort_by(fn {hand, _bid} -> hand end, Hand)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_hand, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end
end

AdventOfCode.Day7.Solver.solve("input")
|> IO.inspect()
