defmodule Solution do
  def parse(s) do
    matches = Regex.named_captures(~r/Game (?<game>\d+):(?<turns>.*)/, s)
    game = String.to_integer(matches["game"])
    turns = String.split(matches["turns"], ";")
            |> Enum.map(fn turn ->
              String.split(turn, ",") 
              |> Enum.map(fn x ->
                [n, c] = String.split(x)
                {c, String.to_integer(n)}
              end)
            end)
    {game, turns}
  end

  def valid_part1({_game, turns}) do
    turns
    |> Enum.concat
    |> Enum.map(&pair_valid?/1)
    |> Enum.all?
  end

  def sum_games(games) do
    Enum.sum(for {game, _turns} <- games, do: game)
  end

  defp pair_valid?({"green", count}), do: count <= 13
  defp pair_valid?({"red", count}), do: count <= 12
  defp pair_valid?({"blue", count}), do: count <= 14

  def power_of_cubes_needed({_game, turns}) do
    Enum.concat(turns)
    |> Enum.group_by(fn {color, _count} -> color end,
      fn {_color, count} -> count end)
      |> Enum.map(fn {_color, counts} -> Enum.max(counts) end)
      |> Enum.product
  end
end

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.parse/1)
  |> Enum.filter(&Solution.valid_part1/1)
  |> Solution.sum_games
  |> IO.puts

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.parse/1)
  |> Enum.map(&Solution.power_of_cubes_needed/1)
  |> Enum.sum
  |> IO.puts
