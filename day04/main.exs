
defmodule Solution do

  defp split_nums(s) do
    String.split(s) |> MapSet.new(&String.to_integer/1)
  end

  def parse(line) do
    parts = Regex.named_captures(~r/Card +(?<cardno>\d+):(?<wins>.*)\|(?<haves>.*)/, line)
    %{ game: String.to_integer(parts["cardno"]), wins: split_nums(parts["wins"]), haves: split_nums(parts["haves"]) }
  end

  def score(card) do
    case num_matches(card) do
      0 -> 0
      n -> :math.pow(2, n-1) |> round()
    end
  end

  defp num_matches(card) do
    MapSet.intersection(card.wins, card.haves) |> MapSet.size()
  end

  def part2(cards) do
    initial_state = Enum.into(cards, %{}, &({&1.game, %{score: num_matches(&1), n: 1}}))
    Enum.reduce(1..length(cards), initial_state,
      fn card, results ->
        if results[card].score > 0 do
          Enum.reduce(card+1..card+results[card].score, results,
            fn n, results -> Map.update!(results, n,
              fn %{score: score, n: n} -> %{score: score, n: n + results[card].n} end)
            end)
        else
          results
        end
      end)
  end
end

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.parse/1)
  |> Enum.map(&Solution.score/1)
  |> Enum.sum()
  |> IO.inspect

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.parse/1)
  |> Solution.part2()
  |> Enum.map(fn {_, %{n: n}} -> n end)
  |> Enum.sum()
  |> IO.inspect
