
defmodule BasicMath do
  def gcd(a, 0), do: trunc(a)
  def gcd(0, b), do: trunc(b)
  def gcd(a, b), do: trunc(gcd(b, rem(a, b)))
  def lcm(0, 0), do: 0
  def lcm(a, b), do: trunc((a*b)/gcd(a, b))
  end

defmodule Solution do

  defp parse_net_data(data) do
    for line <- String.split(data, "\n", trim: true), into: %{}  do
      [_, from, left, right] = Regex.run(~r/(...) = \((...), (...)\)/, line)
      {from, {left, right}}
    end
  end

  def part1(input) do
    [route, net_data] = String.split(input, "\n\n")
    net = parse_net_data(net_data)
    String.codepoints(route) |> Stream.cycle() |> Stream.transform("AAA", fn i, acc ->
      next = Map.fetch!(net, acc) |> then(fn {left, right} ->
        case i do
          "L" -> left
          "R" -> right
        end
      end)
      if next == "ZZZ", do: {:halt, next}, else: {[i], next}
    end) |> stream_length() |> then(&(&1 + 1))
  end

  def stream_length(stream) do
    stream |>
    Stream.concat([:end])
    |> Stream.transform(0, fn i, acc -> if i == :end, do: {[acc], acc}, else: {[], acc + 1} end)
    |> Enum.into([])
    |> List.first()
  end

  def find_offset_and_period(start, route, net) do
    [first, second] = String.codepoints(route) |> Stream.cycle() |> Stream.transform(start, fn i, acc ->
      next = Map.fetch!(net, acc) |> then(fn {left, right} ->
        case i do
          "L" -> left
          "R" -> right
        end
      end)
      {[{acc, i}], next}
    end)
    |> Stream.with_index()
    |> Stream.filter(fn {{node, _}, _} -> String.ends_with?(node, "Z") end)
    |> Stream.map(fn {_, i} -> i end)
    |> Stream.take(2)
    |> Enum.to_list()
    {first, second - first}
  end

  def part2(input) do
    [route, net_data] = String.split(input, "\n\n")
    net = parse_net_data(net_data)
    starts = Map.keys(net) |> Enum.filter(&(String.ends_with?(&1, "A")))
    for start <- starts do
      find_offset_and_period(start, route, net)
    end
    |> Enum.map(fn {a, a} -> a end)
    |> Enum.reduce(&BasicMath.lcm/2)
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
