defmodule AdventOfCode.Day5.Mapping do
  defstruct [:source, :destination, :offset]

  def new(source_id, destination_id, length) do
    %__MODULE__{
      source: Range.new(source_id, source_id + length - 1),
      destination: destination_id,
      offset: destination_id - source_id
    }
  end

  def map(%__MODULE__{} = mapping, id) do
    if id in mapping.source,
      do: mapping.destination + offset(mapping, id),
      else: nil
  end

  defp offset(%__MODULE__{source: start.._}, id), do: id - start
end

defmodule AdventOfCode.Day5.Reader do
  def read(file) do
    initital_state = %{
      mode: nil,
      seeds: [],
      seed_to_soil: [],
      soil_to_fertilizer: [],
      fertilizer_to_water: [],
      water_to_light: [],
      light_to_temperature: [],
      temperature_to_humidity: [],
      humidity_to_location: []
    }

    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(String.length(&1) > 0))
    |> Enum.reduce(initital_state, &read_line/2)
  end

  defp read_line("seeds: " <> seed_input, state) do
    seeds =
      seed_input
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    %{state | seeds: seeds}
  end

  defp read_line(line, state) do
    if header?(line),
      do: update_reader_mode(line, state),
      else: parse_data(line, state)
  end

  def header?(line), do: String.ends_with?(line, " map:")

  def update_reader_mode(header, state) do
    mode =
      header
      |> String.split()
      |> hd()
      |> String.replace("-", "_")
      |> String.to_atom()

    %{state | mode: mode}
  end

  def parse_data(line, state) do
    [dest, src, length] =
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    mapping = AdventOfCode.Day5.Mapping.new(src, dest, length)
    Map.update!(state, state.mode, &[mapping | &1])
  end
end

defmodule AdventOfCode.Day5.Solver do
  alias AdventOfCode.Day5.Mapping
  alias AdventOfCode.Day5.Reader

  def solve(file) do
    game_state = Reader.read(file)

    game_state.seeds
    |> Enum.map(&location_of(&1, game_state))
    |> Enum.min()
  end

  def solve_part_2(file) do
    game_state = Reader.read(file)

    all_seeds =
      game_state.seeds
      |> Stream.chunk_every(2)
      |> Stream.map(fn [start, length] -> Range.new(start, start + length - 1) |> IO.inspect() end)
      |> Stream.flat_map(&Enum.to_list/1)

    all_seeds
    |> Stream.map(&location_of(&1, game_state))
    |> Enum.min()
  end

  defp location_of(seed_id, game_state) do
    [
      :seed_to_soil,
      :soil_to_fertilizer,
      :fertilizer_to_water,
      :water_to_light,
      :light_to_temperature,
      :temperature_to_humidity,
      :humidity_to_location
    ]
    |> Enum.reduce(seed_id, &find_mapping(game_state, &1, &2))

    # |> IO.inspect(label: "Seed #{seed_id}")
  end

  defp find_mapping(game_state, mapping, id) do
    IO.puts("Finding #{mapping} for id #{id} in #{inspect(game_state[mapping])}")
    Enum.find_value(game_state[mapping], id, &Mapping.map(&1, id))
  end
end

AdventOfCode.Day5.Solver.solve("input") |> IO.inspect()
