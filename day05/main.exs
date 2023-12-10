
defmodule Mapper do
  defmodule R do
    defstruct range: nil, offset: 0
  end

  defstruct ranges: []

  defp make_range_map([dest, source, len]) do
    %R{range: source..source+len, offset: dest-source}
  end

  def new(data) do
    %Mapper{ranges: String.split(data, "\n", trim: true) |> Enum.map(fn line ->
      String.split(line) |> Enum.map(&String.to_integer/1) |> make_range_map()
    end)}
  end

  def map(n, mapper) do
    Enum.reduce_while(mapper.ranges, n, fn m, _ ->
      if n in m.range do
        {:halt, n + m.offset}
      else
        {:cont, n}
      end
    end)
  end

  defp range_shift(first..last//step, by), do: (first+by)..(last+by)//step

  # Returns {unmapped, mapped}
  defp map_range(range, using) do
    cond do
      Range.disjoint?(range,using.range) -> {[range], []}
      using.range.first == range.first ->
        if using.range.last == range.last || using.range.last not in range do
          {[], [range_shift(range, using.offset)]}
        else
          {[using.range.last+1..range.last], [range_shift(range.first..using.range.last, using.offset)]}
        end
      using.range.first in range ->
        if using.range.last == range.last || using.range.last not in range do
          {[range.first..using.range.first-1], [range_shift(using.range.first..range.last, using.offset)]}
        else
          {[range.first..using.range.first-1, using.range.last+1..range.last],
            [range_shift(using.range.first..using.range.last, using.offset)]}
        end
      using.range.last == range.last -> {[], [range_shift(range, using.offset)]}
      using.range.last in range -> {[using.range.last+1..range.last], [range_shift(range.first..using.range.last, using.offset)]}
      true -> {[], [range_shift(range, using.offset)]}
    end
  end

  # [{[a,b], [c,d]}, {[e,f], [g,h]}, ...] ==> {[a,b,e,f], [c,d,g,h]}
  defp merge_tuples(tuples) do
    Enum.reduce(tuples, {[], []}, fn {t1, t2}, {acc1, acc2} -> {t1 ++ acc1, t2 ++ acc2} end)
  end

  def map_ranges(ranges, mapper) do
    Enum.reduce(mapper.ranges, {ranges, []}, fn r, {unmapped, mapped} ->
      Enum.map(unmapped, fn range -> map_range(range, r) end)
      |> merge_tuples()
      |> then(fn {unmapped, newly_mapped} -> {unmapped, mapped ++ newly_mapped} end)
    end) |> then(fn {unmapped, mapped} -> unmapped ++ mapped end)
  end
end

defmodule Solution do

  defp parse_section(section) do
    [_, data] = String.split(section, ":")
    Mapper.new(data)
  end

  defp parse_seeds1(section) do
    section |> String.split(":")
            |> then(fn [_, data] -> data end)
            |> String.split()
            |> Enum.map(&String.to_integer/1)
  end

  defp parse_maps(sections) do
    %{
      soils: Enum.at(sections, 1) |> parse_section(),
      fertilizers: Enum.at(sections, 2) |> parse_section(),
      water: Enum.at(sections, 3) |> parse_section(),
      light: Enum.at(sections, 4) |> parse_section(),
      temperature: Enum.at(sections, 5) |> parse_section(),
      humidity: Enum.at(sections, 6) |> parse_section(),
      location: Enum.at(sections, 7) |> parse_section(),
    }
  end

  def part1(data) do
    sections = String.split(data, "\n\n")
    seeds = Enum.at(sections, 0) |> parse_seeds1()
    maps = parse_maps(sections)

    Enum.map(seeds, fn seed ->
      Mapper.map(seed, maps.soils)
      |> Mapper.map(maps.fertilizers)
      |> Mapper.map(maps.water)
      |> Mapper.map(maps.light)
      |> Mapper.map(maps.temperature)
      |> Mapper.map(maps.humidity)
      |> Mapper.map(maps.location) end)
      |> Enum.min()
  end

  defp parse_seeds2(section) do
    section
    |> String.split(":")
    |> then(fn [_, data] -> data end)
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, len] -> start..start+len-1 end)
  end

  def part2(data) do
    sections = String.split(data, "\n\n")
    seeds = Enum.at(sections, 0) |> parse_seeds2()

    maps = parse_maps(sections)

    seeds |> Mapper.map_ranges(maps.soils)
    |> Mapper.map_ranges(maps.fertilizers)
    |> Mapper.map_ranges(maps.water)
    |> Mapper.map_ranges(maps.light)
    |> Mapper.map_ranges(maps.temperature)
    |> Mapper.map_ranges(maps.humidity)
    |> Mapper.map_ranges(maps.location)
    |> Enum.min()
    |> then(fn first.._ -> first end)
  end

end

System.argv()
  |> File.read!()
  |> Solution.part1()
  |> IO.inspect()

System.argv()
  |> File.read!()
  |> Solution.part2()
  |> IO.inspect()
