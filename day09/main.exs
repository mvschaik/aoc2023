

defmodule Solution do

  defp distances(elements) do
    Enum.chunk_every(elements, 2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
  end

  defp get_next_element(elements) do
    if map_size(Enum.frequencies(elements)) == 1 do
      List.first(elements)
    else
      get_next_element(distances(elements)) + List.last(elements)
    end
  end

  def part1(input) do
    for line <- String.split(input, "\n", trim: true) do
      String.split(line) |> Enum.map(&String.to_integer/1) |> get_next_element()
    end |> Enum.sum()
  end

  def part2(input) do
    for line <- String.split(input, "\n", trim: true) do
      String.split(line) |> Enum.map(&String.to_integer/1) |> Enum.reverse() |> get_next_element()
    end |> Enum.sum()
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
