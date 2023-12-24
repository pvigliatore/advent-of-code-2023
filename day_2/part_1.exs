defmodule AdventOfCode.Day2 do
  alias AdventOfCode.Day2.Game
  alias AdventOfCode.Day2.GameFactory

  def part_1(input \\ "input") do
    input
    |> File.stream!()
    |> Stream.map(&GameFactory.parse_game/1)
    |> Stream.filter(&Game.possible?(&1, 12, 13, 14))
    |> Stream.map(& &1.id)
    |> Enum.sum()
  end

  def part_2(input \\ "input") do
    input
    |> File.stream!()
    |> Stream.map(&GameFactory.parse_game/1)
    |> Stream.map(&(&1.red * &1.green * &1.blue))
    |> Enum.sum()
  end
end

defmodule AdventOfCode.Day2.GameFactory do
  def parse_game(game_line) do
    [game_id, cubesets] = Regex.run(~r/Game (\d+): (.*)/, game_line, capture: :all_but_first)

    AdventOfCode.Day2.Game.new(
      String.to_integer(game_id),
      parse_all_cubesets(cubesets)
    )
  end

  def parse_all_cubesets(input) do
    input
    |> String.split("; ")
    |> Enum.map(&parse_cubeset/1)
  end

  def parse_cubeset(cubsets_line) do
    cubsets_line
    |> String.split(", ")
    |> Map.new(fn input ->
      [num, color] = String.split(input)
      {String.to_atom(color), String.to_integer(num)}
    end)
    |> Enum.into(%{
      red: 0,
      green: 0,
      blue: 0
    })
  end
end

defmodule AdventOfCode.Day2.Game do
  defstruct id: nil, red: 0, green: 0, blue: 0

  def new(id, cubesets) do
    Enum.reduce(cubesets, %__MODULE__{id: id}, fn cubeset, game ->
      struct(game, %{
        red: max(game.red, cubeset.red),
        green: max(game.green, cubeset.green),
        blue: max(game.blue, cubeset.blue)
      })
    end)
  end

  def possible?(game, max_red_cubes, max_green_cubes, max_blue_cubes) do
    game.red <= max_red_cubes and
      game.green <= max_green_cubes and
      game.blue <= max_blue_cubes
  end
end

# AdventOfCode.Day2.run("part-1-sample")
IO.inspect(AdventOfCode.Day2.part_1(), label: "Part 1")
IO.inspect(AdventOfCode.Day2.part_2(), label: "Part 2")
