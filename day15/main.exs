
defmodule Solution do
  def hash(s) do
    Enum.reduce(String.to_charlist(s), 0, fn n, acc -> rem(17 * (acc + n), 256) end)
  end

  def part1(input) do
    String.trim(input) |> String.split(",") |> Enum.map(&hash/1) |> Enum.sum()
  end

  def del_key(map, key) do
    List.update_at(map, hash(key), &(List.keydelete(&1, key, 0)))
  end

  def add_key_value(map, key, value) do
    List.update_at(map, hash(key), &(List.keystore(&1, key, 0, {key, value})))
  end

  def update_map(map, cmd) do
    if String.ends_with?(cmd, "-") do
      del_key(map, String.trim(cmd, "-"))
    else
      [k, v] = String.split(cmd, "=")
      add_key_value(map, k, String.to_integer(v))
    end
  end

  def score(map) do
    Enum.with_index(map, 1)
    |> Enum.map(fn {l, box} ->
      Enum.with_index(l, 1)
      |> Enum.map(fn {{_, v}, slot} -> box * slot * v end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    String.trim(input)
    |> String.split(",")
    |> Enum.reduce(List.duplicate([], 256), fn cmd, map -> update_map(map, cmd) end)
    |> score()
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
