defmodule AdventOfCode.Day5.Mapping do
  @moduledoc """
  A mapping between locations, e.g. seed-to-soil mapping
  """

  defstruct [:source, :destination]

  def new(source_id, destination_id, length) do
    %__MODULE__{
      source: Range.new(source_id, source_id + length - 1),
      destination: Range.new(destination_id, destination_id + length - 1)
    }
  end

  def fit(%__MODULE__{} = mapping, first_id..last_id) do
    contains_first_id = first_id in mapping.source
    contains_last_id = last_id in mapping.source

    case {contains_first_id, contains_last_id} do
      {true, true} ->
        {:ok, map(mapping, first_id..last_id)}

      {true, false} ->
        mapped_ids = map(mapping, first_id..mapping.source.last)
        overflow_ids = (mapping.source.last + 1)..last_id
        {:ok, mapped_ids, overflow_ids}

      {false, true} ->
        {:ok, map(mapping, mapping.source.first..last_id)}

      {false, false} ->
        {:error, :out_of_bounds}
    end
  end

  defp map(%__MODULE__{} = mapping, ids) do
    if ids.first in mapping.source and ids.last in mapping.source do
      Range.shift(ids, offset(mapping))
    else
      raise ArgumentError
    end
  end

  @doc """
  Create a densely populated stream of mappings, padding the gaps with
  direct mappings. For example, in a seed-to-soil map where the seed ids
  are 1..10 and 20..30, the seed ids 11..19 map directly to soil id 11..19.
  """
  def pad(mappings, until) do
    mappings
    |> maybe_pad_leading()
    |> maybe_pad_trailing(until)
    |> Enum.sort_by(& &1.source)
    |> Stream.unfold(fn
      [] ->
        nil

      [last] ->
        {last, []}

      [first, second | rest] ->
        if consecutive?(first, second) do
          # there's no gap to fill
          {first, [second | rest]}
        else
          # fill the gap
          infill_start = first.source.last + 1
          infill_end = second.source.first - 1
          infill = __MODULE__.new(infill_start, infill_start, infill_end - infill_start + 1)
          {first, [infill, second | rest]}
        end
    end)
    |> Enum.to_list()
  end

  defp maybe_pad_leading(mappings) do
    %{source: first_id.._} = Enum.min_by(mappings, & &1.source)

    case first_id do
      0 -> mappings
      id -> [new(0, 0, id) | mappings]
    end
  end

  defp maybe_pad_trailing(mappings, until) do
    %{source: _..last_id} = Enum.max_by(mappings, & &1.source)

    if last_id >= until,
      do: mappings,
      else: [new(last_id + 1, last_id + 1, until - last_id) | mappings]
  end

  defp consecutive?(%__MODULE__{} = left, %__MODULE__{} = right) do
    left.source.last + 1 == right.source.first
  end

  defp offset(mapping), do: mapping.destination.first - mapping.source.first
end

defmodule AdventOfCode.Day5.Reader do
  def read(file) do
    seeds =
      file
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.take(1)
      |> hd()
      |> read_seeds()

    mappings =
      file
      |> File.stream!()
      |> Stream.drop(3)
      |> Stream.map(&String.trim/1)
      |> Stream.reject(fn line -> String.length(line) == 0 end)
      |> Enum.chunk_while(
        [],
        &chunk_mappings/2,
        &chunk_mappings(" map:", &1)
      )

    {seeds, mappings}
  end

  def header?(line), do: String.ends_with?(line, " map:")

  defp chunk_mappings(line, mappings) do
    # return a new chunk when we encounter the next header
    if header?(line) do
      {:cont, mappings, []}
    else
      mapping = parse_mapping(line)
      {:cont, [mapping | mappings]}
    end
  end

  defp read_seeds("seeds: " <> seed_input) do
    seed_input
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.map(fn [start, length] -> Range.new(start, start + length - 1) end)
    |> Enum.sort()
  end

  def parse_mapping(line) do
    [dest, src, length] =
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    AdventOfCode.Day5.Mapping.new(src, dest, length)
  end
end

defmodule AdventOfCode.Day5.Solver do
  alias AdventOfCode.Day5.Mapping
  alias AdventOfCode.Day5.Reader

  def solve(file) do
    {seeds,
     [
       seed_to_soil,
       soil_to_fertilizer,
       fertilizer_to_water,
       water_to_light,
       light_to_temperature,
       temperature_to_humidity,
       humidity_to_location
     ]} = Reader.read(file)

    seeds
    |> flatten(seed_to_soil)
    |> flatten(soil_to_fertilizer)
    |> flatten(fertilizer_to_water)
    |> flatten(water_to_light)
    |> flatten(light_to_temperature)
    |> flatten(temperature_to_humidity)
    |> flatten(humidity_to_location)
    |> Stream.map(& &1.first)
    |> Enum.min()
  end

  def flatten(ids, mappings) do
    max_id =
      mappings
      |> Enum.max_by(& &1.source)
      |> then(& &1.source.last)

    padded_mappings = Mapping.pad(mappings, max_id)

    flatten([], ids, padded_mappings)
  end

  defp flatten(acc, [], _mappings) do
    acc
  end

  defp flatten(acc, [ip_range | next_ip_ranges], []) do
    flatten([ip_range | acc], next_ip_ranges, [])
  end

  defp flatten(acc, id_ranges, mappings) do
    [first_id_range | next_id_ranges] = id_ranges
    [first_mapping | next_mappings] = mappings

    case Mapping.fit(first_mapping, first_id_range) do
      {:ok, range} ->
        flatten([range | acc], next_id_ranges, mappings)

      {:ok, range, unused_ids} ->
        flatten([range | acc], [unused_ids | next_id_ranges], next_mappings)

      {:error, :out_of_bounds} ->
        flatten(acc, id_ranges, next_mappings)
    end
    |> Enum.sort()
  end
end

AdventOfCode.Day5.Solver.solve("input")
|> IO.inspect()
