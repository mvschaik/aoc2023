
defmodule Solution do
  def parse(input, expansion \\ 2) do
    lines= String.split(input, "\n", trim: true)
    col_offsets = Enum.scan(0..String.length(List.first(lines))-1, 0, fn i, acc -> 
      if Enum.all?(lines, &(String.at(&1, i) == ".")), do: acc + expansion - 1, else: acc
    end)
    row_offsets = Enum.scan(lines, 0, fn line, acc ->
      if line =~ ~r/^\.*$/, do: acc + expansion - 1, else: acc
    end)
    for {line, row} <- Enum.with_index(lines) do
      for {c, col} <- String.graphemes(line) |> Enum.with_index(),
        c == "#" do
          {row + Enum.at(row_offsets, row),
            col + Enum.at(col_offsets, col)}
        end
    end |> List.flatten()
  end

  defp combinations([]), do: []
  defp combinations([head|tail]) do
    for other <- tail do
      {head, other}
    end ++ combinations(tail)
  end

  defp distance({r1, c1}, {r2, c2}), do: abs(r1-r2) + abs(c1-c2)

  def distances(galaxies) do
    combinations(galaxies) |> Enum.map(fn {a, b} -> distance(a, b) end) |> Enum.sum()
  end
end

System.argv()
|> File.read!()
|> Solution.parse()
|> Solution.distances()
|> IO.inspect()

System.argv()
|> File.read!()
|> Solution.parse(10)
|> Solution.distances()
|> IO.inspect()

System.argv()
|> File.read!()
|> Solution.parse(100)
|> Solution.distances()
|> IO.inspect()

System.argv()
|> File.read!()
|> Solution.parse(1000000)
|> Solution.distances()
|> IO.inspect()
