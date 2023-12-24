defmodule AdventOfCode.Day4.ScratchCard do
  @enforce_keys [:id, :winning_numbers, :numbers]
  defstruct [:id, :winning_numbers, :numbers, :matches, :score]

  def new(id, winning_numbers, numbers) do
    matches = tabulate_matches(Enum.sort(winning_numbers), Enum.sort(numbers))
    score = if matches == 0, do: 0, else: Integer.pow(2, matches - 1)

    %__MODULE__{
      id: id,
      winning_numbers: winning_numbers,
      numbers: numbers,
      matches: matches,
      score: score
    }
  end

  defp tabulate_matches(winning_numbers, numbers, matches \\ 0)

  defp tabulate_matches(winning_numbers, numbers, matches)
       when winning_numbers == [] or numbers == [] do
    matches
  end

  defp tabulate_matches(winning_numbers, numbers, matches) do
    next_winning = hd(winning_numbers)
    next_number = hd(numbers)

    cond do
      next_winning == next_number ->
        tabulate_matches(tl(winning_numbers), tl(numbers), matches + 1)

      next_winning < next_number ->
        tabulate_matches(tl(winning_numbers), numbers, matches)

      next_winning > next_number ->
        tabulate_matches(winning_numbers, tl(numbers), matches)

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
    id = card_input |> String.slice(5..7) |> String.trim() |> String.to_integer()
    winning_numbers = parse_numbers(winning_number_input)
    numbers = parse_numbers(number_input)
    AdventOfCode.Day4.ScratchCard.new(id, winning_numbers, numbers)
  end

  def parse_numbers(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule AdventOfCode.Day4.Solver do
  def solve(file) do
    cards = AdventOfCode.Day4.Reader.read(file)
    single_copies = for card <- cards, into: %{}, do: {card.id, 1}

    copies =
      Enum.reduce(cards, single_copies, fn card, copies ->
        case card.matches do
          0 ->
            copies

          matches ->
            bonus_card_ids = Range.new(card.id + 1, card.id + matches)
            bonus_card_count = Map.fetch!(copies, card.id)
            update_copies(copies, bonus_card_ids, bonus_card_count)
        end
      end)

    copies
    |> Map.values()
    |> Enum.sum()
  end

  defp add(%{} = copies, card_id, to_add) do
    Map.update!(copies, card_id, fn original_count -> original_count + to_add end)
  end

  defp update_copies(copies, card_ids, count) do
    Enum.reduce(card_ids, copies, fn card_id, acc -> add(acc, card_id, count) end)
  end
end

AdventOfCode.Day4.Solver.solve("input") |> IO.inspect()
