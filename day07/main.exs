
defmodule Solution do

  defp group_score(cards) do
    groups = cards |> Enum.sort() |> Enum.chunk_by(&Function.identity/1) |> Enum.sort_by(&length/1, :desc)
    group_unit = :math.pow(15, 5)
    cond do
      length(groups) == 5 -> 0 * group_unit  # high card
      length(groups) == 4 -> 1 * group_unit  # one pair
      length(groups) == 3 and length(List.first(groups)) == 2 -> 2 * group_unit # Two pair
      length(groups) == 3 and length(List.first(groups)) == 3 -> 3 * group_unit # Three of a kind
      length(groups) == 2 and length(List.first(groups)) == 3 -> 4 * group_unit # Full house
      length(groups) == 2 and length(List.first(groups)) == 4 -> 5 * group_unit # Four of a kind
      length(groups) == 1 -> 6 * group_unit  # Five of a kind
    end
  end


  defp hand_value(cards) do
    cards = String.codepoints(cards) |> Enum.map(&card_value/1)
    card_score = Enum.reduce(cards, 0, fn card, acc -> card + acc * 15 end)
    group_score(cards) + card_score
  end

  defp hand_value2(cards) do
    cards = String.codepoints(cards) |> Enum.map(&card_value2/1)
    card_score = Enum.reduce(cards, 0, fn card, acc -> card + acc * 15 end)
    num_jokers = cards |> Enum.count(&(&1 == 1))
    if num_jokers == 5 do
      group_score(cards) + card_score
    else
      groups = cards |> Enum.filter(&(&1 != 1)) |> Enum.sort() |> Enum.chunk_by(&Function.identity/1) |> Enum.sort_by(&length/1, :desc)
      group_score(List.flatten(groups) ++ (Enum.at(groups, 0) |> Enum.at(0) |> List.duplicate(num_jokers))) + card_score
    end
  end

  defp card_value(card) do
    case card do
      "T" -> 10
      "J" -> 11
      "Q" -> 12
      "K" -> 13
      "A" -> 14
      n -> String.to_integer(n)
    end
  end

  defp card_value2(card) do
    case card do
      "T" -> 10
      "J" -> 1
      "Q" -> 12
      "K" -> 13
      "A" -> 14
      n -> String.to_integer(n)
    end
  end

  def part1(data) do
    for line <- String.split(data, "\n", trim: true) do
      [cards, bid] = String.split(line)
      {hand_value(cards), String.to_integer(bid)}
    end |> Enum.sort()
    |> Enum.map(fn {_, bid} -> bid end)
    |> Enum.with_index(1)
    |> Enum.map(fn {bid, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def part2(data) do
    for line <- String.split(data, "\n", trim: true) do
      [cards, bid] = String.split(line)
      {hand_value2(cards), String.to_integer(bid)}
    end |> Enum.sort()
    |> Enum.map(fn {_, bid} -> bid end)
    |> Enum.with_index(1)
    |> Enum.map(fn {bid, rank} -> bid * rank end)
    |> Enum.sum()
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
