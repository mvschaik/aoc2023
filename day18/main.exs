defmodule Solution do

  def parse_input(input) do
    re = ~r/(?<dir>[UDLR]) (?<dist>\d+) \(#(?<dist2>.{5})(?<dir2>.)\)/
      for line <- String.split(input, "\n", trim: true) do
        match = Regex.named_captures(re, line)
        %{dir: match["dir"],
          dist: String.to_integer(match["dist"]),
          dir2: match["dir2"],
          dist2: String.to_integer(match["dist2"], 16)
        }
    end
  end

  def print_field(field) do
    {min_x, max_x} = Enum.map(field, fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(field, fn {_, y} -> y end) |> Enum.min_max()

    for y <- max_y..min_y do
      min_x..max_x
      |> Enum.map(fn x -> if {x, y} in field, do: "#", else: "." end)
      |> Enum.join()
      |> IO.puts()
    end

    field
  end

  defp neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp dfs([], seen), do: seen
  defp dfs([node|rest], seen) do
    if node in seen do
      dfs(rest, seen)
    else
      dfs(neighbors(node) ++ rest, MapSet.put(seen, node))
    end
  end

  def part1(input) do
    {field, _pos} = Enum.reduce(input, {MapSet.new(), {0,0}}, fn cmd, {field, {x, y}} ->
      range = case cmd.dir do
        "U" -> Enum.zip(List.duplicate(x, cmd.dist), y+1..y+cmd.dist)
        "D" -> Enum.zip(List.duplicate(x, cmd.dist), y-1..y-cmd.dist)
        "R" -> Enum.zip(x+1..x+cmd.dist, List.duplicate(y, cmd.dist))
        "L" -> Enum.zip(x-1..x-cmd.dist, List.duplicate(y, cmd.dist))
      end
      {Enum.reduce(range, field, fn p, f -> MapSet.put(f, p) end), List.last(range)}
    end)

    dfs([{1,-1}], MapSet.new(field)) |> MapSet.size()
  end

  def part2(input) do
    points = [{0,0} | Enum.scan(input, {0, 0}, fn %{dist2: dist, dir2: dir}, {x, y} ->
      case dir do
        d when d in ["0", "R"] -> {x + dist, y}
        d when d in ["1", "D"] -> {x, y - dist}
        d when d in ["2", "L"] -> {x - dist, y}
        d when d in ["3", "U"] -> {x, y + dist}
      end
    end) ]

    len = Enum.chunk_every(points, 2, 1, [{0,0}])
          |> Enum.reduce(0, fn [{x1, y1}, {x2, y2}], acc -> acc + abs(x1-x2) + abs(y1-y2) end)

    points
    |> Enum.chunk_every(2, 1, [{0,0}])
    |> Enum.map(fn [{x1, y1}, {x2, y2}] -> x1 * y2 - x2 * y1 end)
    |> Enum.sum() |> then(&(div(len, 2) + 1 + abs(div(&1,2))))
  end
end

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part1()
|> IO.inspect(label: "Part 1")

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part2()
|> IO.inspect(label: "Part 2")
