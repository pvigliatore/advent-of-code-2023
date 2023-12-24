defmodule AdventOfCode.Day3.PartNumber do
  defstruct [:coord, :length, :part_number]

  def valid?(part_number, symbol_locations) do
    part_number
    |> adjacent_cells()
    |> Enum.any?(&(&1 in symbol_locations))
  end

  def adjacent_cells(%{coord: {row, col}, length: length}) do
    initial = MapSet.new([{row, col - 1}, {row, col + length}])

    Range.new(col - 1, col + length)
    |> Stream.flat_map(&[{row - 1, &1}, {row + 1, &1}])
    |> Enum.reduce(initial, &MapSet.put(&2, &1))
  end
end

defmodule AdventOfCode.Day3 do
  @typep coord :: {integer(), integer()}
  @typep length :: integer()
  @type part_number :: {coord(), length()}

  @type index :: integer()
  @type lengh :: integer()
  @type regex_index :: {index(), length()}

  def read_input(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
  end

  @doc """
  Find the definitionx of all the numbers
  """
  def locate_all_part_numbers(file) do
    file
    |> read_input()
    |> Stream.flat_map(&words/1)
  end

  @doc """
  Find the definitions of all numbers within a line
  """
  def words({input_str, row}) do
    locations = ~r/\d+/ |> Regex.scan(input_str, return: :index) |> Enum.map(&hd/1)
    numbers = ~r/\d+/ |> Regex.scan(input_str) |> Enum.map(&hd/1)

    locations
    |> Stream.zip(numbers)
    |> Enum.map(fn {{col, length}, part_number} ->
      %AdventOfCode.Day3.PartNumber{
        coord: {row, col},
        length: length,
        part_number: part_number
      }
    end)
  end

  @doc """
  Find the coordinates of all the symbols
  """
  def locate_all_symbols(file) do
    file
    |> read_input()
    |> Stream.flat_map(fn {line, row} -> locate_symbols(line, row) end)
    |> MapSet.new()
  end

  def locate_symbols(line, row) do
    ~r/[^0-9.]/
    |> Regex.scan(line, return: :index, collect: :first)
    |> Stream.concat()
    |> Stream.map(fn {col, _} -> {row, col} end)
  end

  def solve_part_1(file \\ "input") do
    all_symbols = locate_all_symbols(file)

    part_numbers =
      file
      |> locate_all_part_numbers()
      |> Enum.filter(&AdventOfCode.Day3.PartNumber.valid?(&1, all_symbols))

    part_numbers
    |> Stream.map(& &1.part_number)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def solve_part_2(file \\ "input") do
    all_symboles = locate_all_symbols(file)
    part_numbers =
      file
      |> locate_all_part_numbers()
      |> Enum.map()

      AdventOfCode.Day3.PartNumber.adjacent_symbols()
  end
end

"input"
|> AdventOfCode.Day3.solve_part_1()
|> IO.inspect()
