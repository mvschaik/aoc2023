defmodule Solution do
  def parse_input(input) do
    for {line, row} <- String.split(input, "\n", trim: true) |> Enum.with_index(),
      {c, col} <- String.to_charlist(line) |> Enum.with_index(), into: %{} do
        {{row, col}, c}
      end
  end

  def interact(d, ?.), do: [d]
  def interact({dr, dc}, ?/), do: [{-dc, -dr}]
  def interact({dr, dc}, ?\\), do: [{dc, dr}]
  def interact({0, _}, ?|), do: [{1, 0}, {-1, 0}]
  def interact(d, ?|), do: [d]
  def interact({_, 0}, ?-), do: [{0, 1}, {0, -1}]
  def interact(d, ?-), do: [d]

  def add({r1, c1}, {r2, c2}), do: {r1+r2, c1+c2}

  def part1(field) do
    num_energized(field, {{0, 0}, {0, 1}})
  end

  def part2(field) do
    {{max_row, max_col}, _} = Enum.max_by(field, fn {{row, col}, _} -> row + col end)
    all_starts = for(row <- 0..max_row, do: [{{row, 0}, {0, 1}}, {{row, max_col}, {0, -1}}]) ++
      for(col <- 0..max_col, do: [{{0, col}, {1, 0}}, {{max_row, col}, {-1, 0}}])
      |> List.flatten()

    Enum.map(all_starts, fn start -> num_energized(field, start) end) |> Enum.max()
  end

  def num_energized(field, start) do
    Stream.unfold({MapSet.new([start]), [start]}, fn {visited, cursors} ->
      new_cursors = Enum.flat_map(cursors, fn {pos, dir} ->
        interact(dir, field[pos]) |> Enum.map(fn new_dir -> {add(pos, new_dir), new_dir} end)
      end)
      |> Enum.reject(&(MapSet.member?(visited, &1)))
      |> Enum.filter(fn {pos, _dir} -> Map.has_key?(field, pos) end)
      if length(new_cursors) == 0 do
        nil
      else
        {visited, {MapSet.union(visited, MapSet.new(new_cursors)), new_cursors}}
      end
    end)
    |> Enum.to_list()
    |> List.last()
    |> Enum.map(fn {pos, _dir} -> pos end)
    |> MapSet.new()
    |> MapSet.size()
  end
end

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part1()
|> IO.inspect()

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part2()
|> IO.inspect()
