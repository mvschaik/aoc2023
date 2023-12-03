
defmodule Solution do

  @digits %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9",
      "zero" => "0",
    }

  def first_digit(s) do
    re = Regex.compile!("(" <> Enum.join(Map.keys(@digits), "|") <> "|\\d)")
    match = List.first(Regex.run(re, s))
    Map.get(@digits, match, match)
  end

  def last_digit(s) do
    re = Regex.compile!("(" <> Enum.map_join(Map.keys(@digits), "|", &String.reverse/1) <> "|\\d)")
    match = List.first(Regex.run(re, String.reverse(s)))
    Map.get(@digits, String.reverse(match), match)
  end

  def part1(s) do
    digits = s |> String.replace(~r/[^\d]/, "")
    number = String.first(digits) <> String.last(digits)
    String.to_integer(number)
  end

  def part2(s) do
    String.to_integer(first_digit(s) <> last_digit(s))
  end

end

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.part1/1)
  |> Enum.sum()
  |> IO.puts()

System.argv()
  |> File.stream!()
  |> Enum.map(&Solution.part2/1)
  |> Enum.sum()
  |> IO.puts()
