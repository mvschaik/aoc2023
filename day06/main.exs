
defmodule Solution do

  defp parse_line(line) do
    [_, numbers] = String.split(line, ":")
    numbers |> String.split() |> Enum.map(&String.to_integer/1)
  end

  defp parse_input(input) do
    [time_line, dist_line] = String.split(input, "\n", trim: true)
    times = parse_line(time_line)
    dists = parse_line(dist_line)
    Enum.zip(times, dists)
  end

  def part1(input) do
    races = parse_input(input)

    for {time, dist} <- races do
      discr = time * time - 4 * dist
      min = Float.ceil(0.00000001 + (time - :math.sqrt(discr)) / 2) |> trunc()
      max = Float.floor(-0.00000001 + (time + :math.sqrt(discr)) / 2) |> trunc()
      Range.size(min..max)
    end |> Enum.product()
  end
end

System.argv()
|> File.read!()
|> Solution.part1()
|> IO.inspect()

System.argv()
|> File.read!()
|> String.replace(" ", "")
|> Solution.part1()
|> IO.inspect()
