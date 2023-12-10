
defmodule Solution do

  defp has_symbol?(s) do
    !Regex.match?(~r/^\.*$/, s)
  end

  def part1(data) do
    lines = String.split(data)
    for {line, row} <- Enum.with_index(lines),
      [{col, len}] <- Regex.scan(~r/\d+/, line, return: :index),
      # Above
      (row > 0 && Enum.at(lines, row-1) |> String.slice(max(col-1, 0)..col+len) |> has_symbol?()) ||
      # Left
      (col > 0 && String.slice(line, col-1, 1) |> has_symbol?()) ||
      # Right
      (String.slice(line, col+len..col+len) |> has_symbol?()) ||
      # Below
      (row < length(lines) - 1 && Enum.at(lines, row+1) |> String.slice(max(col-1, 0)..col+len) |> has_symbol?()) do
        line |> String.slice(col, len) |> String.to_integer
    end |> Enum.sum()
  end

  defp gears_with_offset(str, row, offset) do
    for [{col, 1}] <- Regex.scan(~r/\*/, str, return: :index) do
      {row, col + offset}
    end
  end

  def part2(data) do
    lines = String.split(data)
    for {line, row} <- Enum.with_index(lines),
      [{col, len}] <- Regex.scan(~r/\d+/, line, return: :index),
      gears = Enum.concat([
          # Above
        if(row > 0, do: Enum.at(lines, row - 1) |> String.slice(max(col-1, 0)..col+len), else: "") |> gears_with_offset(row - 1, max(col-1,0)),
          # Left
        if(col > 0, do: String.slice(line, col - 1, 1), else: "") |> gears_with_offset(row, col - 1),
          # Right
        String.slice(line, col+len..col+len) |> gears_with_offset(row, col+len),
          # Below
        if(row < length(lines) - 1, do: Enum.at(lines, row + 1) |> String.slice(max(col-1,0)..col+len), else: "") |> gears_with_offset(row+1, max(col-1,0))
      ]),
      length(gears) == 1 do
        {line |> String.slice(col, len) |> String.to_integer, Enum.at(gears, 0)}
      end |> Enum.group_by(fn {_n, gear} -> gear end, fn {n, _gear} -> n end)
      |> Enum.filter(fn {_gear, numbers} -> length(numbers) == 2 end)
      |> Enum.map(fn {_gear, numbers} -> Enum.product(numbers) end)
      |> Enum.sum()
  end
end

System.argv()
|> File.read!
|> Solution.part1
|> IO.inspect

System.argv()
|> File.read!
|> Solution.part2
|> IO.inspect
