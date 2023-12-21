
defmodule Solution do
  def parse_field(input) do
    for {line, row} <- String.split(input, "\n", trim: true) |> Enum.with_index(),
      {c, col} <- String.graphemes(line) |> Enum.with_index(), into: %{} do
        {{row, col}, c}
      end
  end

  def add_walls(field) do
    {{max_row, max_col}, _} = Enum.max_by(field, fn {{r, c}, _} -> r + c end)
    field
    |> Map.merge(for(c <- -1..max_col+1, into: %{}, do: {{-1, c}, "#"}))
    |> Map.merge(for(r <- -1..max_row+1, into: %{}, do: {{r, -1}, "#"}))
    |> Map.merge(for(c <- -1..max_col+1, into: %{}, do: {{max_row + 1, c}, "#"}))
    |> Map.merge(for(r <- -1..max_row+1, into: %{}, do: {{r, max_col + 1}, "#"}))
  end

  def print_field(field) do
    {{max_row, max_col}, _} = Enum.max_by(field, fn {{r, c}, _} -> r + c end)
    for row <- -1..max_row do
      Enum.map(-1..max_col, fn col -> field[{row, col}] end) |> Enum.join() |> IO.puts()
    end
    field
  end

  def part2(input) do
    field = parse_field(input) |> add_walls()
    {offset, period, map} = Stream.iterate(field, &rotate/1)
                       |> Stream.with_index()
                       |> Stream.transform(%{}, fn {field, i}, map ->
                         if Map.has_key?(map, field) do
                           {[{map[field], i - map[field], map}], map}
                         else
                           {[], Map.put(map, field, i)}
                         end
                       end)
                       |> Stream.take(1)
                       |> Enum.to_list() |> List.first()

    index_needed = rem(1000000000 - offset, period) + offset
    Enum.find(map, fn {_, v} -> v == index_needed end) |> elem(0) |> load()
  end

  def part1a(input) do
    parse_field(input) |> add_walls() |> tilt({1, 0}) |> load()
  end

  def add({row1, col1}, {row2, col2}), do: {row1+row2, col1+col2}

  def load(field) do
    {{max_row, _}, _} = Enum.max_by(field, fn {{r, c}, _} -> r + c end)
    for({{row, _}, c} <- field, c == "O", do: max_row - row)
    |> Enum.sum()
  end

  def clean_rocks(field) do
      Enum.map(field, fn {k, v} -> {k, if(v == "O", do: ".", else: v)} end) |> Enum.into(%{})
  end

  def rotate(field) do
    field |> tilt({1, 0}) |> tilt({0, 1}) |> tilt({-1, 0}) |> tilt({0, -1})
  end

  def tilt(field, direction) do
    clean_rocks(field)
    |> Map.merge(
      for {start, c} <- field, c == "#" do
      Stream.unfold(add(start, direction), &({&1, add(&1, direction)}))
      |> Stream.take_while(&(Map.get(field, &1, "#") != "#"))
      |> Stream.filter(&(field[&1] == "O"))
      |> Enum.to_list()
      |> length()
      |> then(fn n ->
        Stream.unfold({n, add(start, direction)}, fn {n, loc} -> if n > 0, do: {loc, {n-1, add(loc, direction)}} end)
        |> Enum.into(%{}, &({&1, "O"}))
      end)
      end
      |> Enum.reduce(&Map.merge/2)
    )
  end

  def part1(input) do
    field = parse_field(input)
    {{max_row, max_col}, _} = Enum.max_by(field, fn {{r, c}, _} -> r + c end)
    field = Map.merge(field, for(c <- 0..max_col, into: %{}, do: {{-1, c}, "#"}))
    for {{row, col}, c} <- field, c == "#" do
        Enum.take_while(row+1..max_row, &(field[{&1, col}] != "#"))
        |> Enum.filter(&(field[{&1, col}] == "O"))
        |> length()
        |> then(fn len -> if len > 0, do: max_row-row..max_row-row-len+1, else: 0..0 end)
        |> Enum.sum()
    end  |> Enum.sum()
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
