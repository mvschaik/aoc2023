
defmodule Solution do
  def parse_input(input) do
    field = for {line, row} <- String.split(input, "\n", trim: true) |> Enum.with_index() do
      for {c, col} <- String.graphemes(line) |> Enum.with_index(), into: %{} do
        connections = case c do
          "." -> []
          "|" -> [{row-1, col}, {row+1, col}]
          "-" -> [{row, col-1}, {row, col+1}]
          "L" -> [{row-1, col}, {row, col+1}]
          "J" -> [{row-1, col}, {row, col-1}]
          "7" -> [{row, col-1}, {row+1, col}]
          "F" -> [{row, col+1}, {row+1, col}]
          "S" -> :start
        end
        {{row, col}, connections}
      end
    end |> Enum.reduce(&Map.merge/2)
    start = Enum.filter(field, fn {_k, v} -> v == :start end)
            |> Enum.map(fn {k, _} -> k end)
            |> List.first()
    {start,
      %{field | start => Enum.filter(field, fn {_k, v} ->
        is_list(v) and start in v end) |> Enum.map(fn {k, _} -> k end)}}
  end

  defp path({start, field}) do
    Stream.unfold({Map.fetch!(field, start) |> List.first(), start}, fn {prev, curr} ->
      next = Map.fetch!(field, curr) |> Enum.filter(&(&1 != prev)) |> List.first()
      if next == start, do: nil, else: {next, {curr, next}}
    end) |> Stream.concat([start]) |> Enum.to_list()
  end

  def part1({start, field}) do
    path({start, field}) |> length() |> then(&(trunc(&1 / 2)))
  end

  defp double(path) do
    {result, _acc} = Enum.flat_map_reduce(path, List.last(path),
      fn curr = {row, col}, {prev_row, prev_col} ->
        {[{row + prev_row, col + prev_col}, {row * 2, col * 2}], curr}
      end)
    result
  end

  defp neighbors({row, col}) do
    [{row + 1, col}, {row - 1, col}, {row, col + 1}, {row, col - 1}]
  end

  defp dfs([], seen), do: seen
  defp dfs([node|rest], seen) do
    if node in seen do
      dfs(rest, seen)
    else
      dfs(neighbors(node) ++ rest, MapSet.put(seen, node))
    end
  end

  def even?(n), do: rem(n, 2) == 0

  def part2(input = {{srow, scol}, _}) do
    path = path(input) |> double() |> MapSet.new()

    # Guessing that row+1 and col-1 are inside the loop...
    dfs([{2*srow+1, 2*scol-1}], MapSet.new(path))
    |> MapSet.new()
    |> MapSet.difference(path)
    |> Enum.filter(fn {row, col} -> even?(row) and even?(col) end)
    |> length()
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
