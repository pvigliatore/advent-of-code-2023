defmodule AdventOfCode.Day3.Part do
  defstruct [:coord, :length, :part_number]

  def adjacent_to?(%__MODULE__{} = part, {target_row, target_col}) do
    {part_row, part_col} = part.coord
    adjacent_row? = part_row - target_row in -1..1
    adjacent_col? = target_col in Range.new(part_col - 1, part_col + part.length)
    adjacent_row? && adjacent_col?
  end
end

defmodule AdventOfCode.Day3.PartReader do
  def read(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.flat_map(&read_line/1)
  end

  def read_line({line, row}) do
    locations = ~r/\d+/ |> Regex.scan(line, return: :index) |> Enum.map(&hd/1)
    numbers = ~r/\d+/ |> Regex.scan(line) |> Enum.map(&hd/1)

    locations
    |> Stream.zip(numbers)
    |> Enum.map(fn {{col, length}, part_number} ->
      %AdventOfCode.Day3.Part{
        coord: {row, col},
        length: length,
        part_number: String.to_integer(part_number)
      }
    end)
  end
end

defmodule AdventOfCode.Day3.Gear do
  @enforce_keys [:coord]
  defstruct coord: nil, parts: []

  def read_coords(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, row} -> read_coords(line, row) end)
  end

  def read_coords(line, row) do
    ~r/\*/
    |> Regex.scan(line, return: :index)
    |> Enum.map(fn [{col, _}] -> {row, col} end)
  end

  def gear_ratio(%__MODULE__{} = gear) do
    [part_1, part_2] = gear.parts
    part_1.part_number * part_2.part_number
  end
end

defmodule AdventOfCode.Day3 do
  alias AdventOfCode.Day3.Gear
  alias AdventOfCode.Day3.Part
  alias AdventOfCode.Day3.PartReader

  def solve(file \\ "input") do
    gear_coords = Gear.read_coords(file)
    parts = PartReader.read(file)

    for gear_coord <- gear_coords, part <- parts, Part.adjacent_to?(part, gear_coord) do
      {gear_coord, part}
    end
    |> Enum.group_by(
      fn {gear_coord, _part} -> gear_coord end,
      fn {_gear_coord, part} -> part end
    )
    |> Stream.filter(fn {_, parts} -> length(parts) == 2 end)
    |> Stream.map(fn {gear_coord, parts} -> %Gear{coord: gear_coord, parts: parts} end)
    |> Enum.to_list()
    |> Stream.map(&Gear.gear_ratio/1)
    |> Enum.sum()
  end
end

"sample"
|> AdventOfCode.Day3.solve()
|> IO.inspect()
