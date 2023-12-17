
defmodule Solution do

  def parse_field(input) do
    for {line, row} <- String.split(input, "\n", trim: true) |> Enum.with_index(),
      {c, col} <- String.graphemes(line) |> Enum.with_index(), into: %{} do
        {{row, col}, c}
      end
  end

  def reflect_horizontally(field, reflect_after) do
    field |> Enum.into(%{}, fn {{row, col}, c} -> {{-row + 2 * reflect_after + 1, col}, c} end)
  end

  def reflect_vertically(field, reflect_after) do
    field |> Enum.into(%{}, fn {{row, col}, c} -> {{row, -col + 2 * reflect_after + 1}, c} end)
  end

  def matches?(field1, field2, smudges \\ 0) do
    field1
    |> Enum.map(fn {coords, val} -> Map.get(field2, coords, val) == val end)
    |> Enum.filter(fn x -> not x end)
    |> length() == smudges
  end

  def horizontal_reflections(field, smudges \\ 0) do
    row_range = Map.keys(field)
                |> Enum.min_max_by(fn {row, _col} -> row end)
                |> then(fn {{min, _}, {max, _}} -> min..max-1 end)
    for row <- row_range,
      reflect_horizontally(field, row) |> matches?(field, smudges) do
        row + 1
      end |> Enum.sum()
  end

  def vertical_reflections(field, smudges \\ 0) do
    col_range = Map.keys(field)
                |> Enum.min_max_by(fn {_row, col} -> col end)
                |> then(fn {{_, min}, {_, max}} -> min..max-1 end)
    for col <- col_range,
      reflect_vertically(field, col) |> matches?(field, smudges) do
        col + 1
      end |> Enum.sum()
  end

  def size(field) do
    Map.keys(field) |> Enum.max_by(fn {row, col} -> row + col end)
  end

  def print_field(field) do
    {max_row, max_col} = size(field)
    for row <- 0..max_row do
      Enum.map(0..max_col, fn col -> field[{row, col}] end) |> Enum.join() |> IO.puts()
    end
    field
  end

  def solve(input, smudges \\ 0) do
    fields = String.split(input, "\n\n") |> Enum.map(&parse_field/1)
    for field <- fields do
      horizontal_reflections(field, smudges) * 100 + vertical_reflections(field, smudges)
    end |> Enum.sum()
  end
end

System.argv()
|> File.read!()
|> Solution.solve()
|> IO.inspect()
System.argv()
|> File.read!()
|> Solution.solve(2)
|> IO.inspect()
