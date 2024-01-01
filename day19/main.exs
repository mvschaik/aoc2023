defmodule Solution do
  def parse_part(s) do
    caps = Regex.named_captures(~r/{x=(?<x>\d+),m=(?<m>\d+),a=(?<a>\d+),s=(?<s>\d+)}/, s)
    %{
      "x" => String.to_integer(caps["x"]),
      "m" => String.to_integer(caps["m"]),
      "a" => String.to_integer(caps["a"]),
      "s" => String.to_integer(caps["s"]),
    }
  end

  def parse_clause(s) do
    cond do
      (match = Regex.run(~r/([xmas])(<|>)(\d+):(.+)/, s)) ->
        [_, xmas, comp, val, action] = match
        {(if comp == "<", do: :lt, else: :gt), xmas, String.to_integer(val), parse_clause(action)}
      s == "A" -> :accept
      s == "R" -> :reject
      true -> {:goto, s}
    end
  end

  def parse_rule(s) do
    caps = Regex.named_captures(~r/(?<name>[^{]+){(?<steps>[^}]+)}/, s)
    steps = String.split(caps["steps"], ",")
            |> Enum.map(&parse_clause/1)
    {caps["name"], steps}
  end

  def run_rule(part, [rule|rest], rules) do
    case rule do
      :accept -> part["x"] + part["m"] + part["a"] + part["s"]
      :reject -> 0
      {:lt, xmas, val, action} -> if part[xmas] < val, do: run_rule(part, [action], rules), else: run_rule(part, rest, rules)
      {:gt, xmas, val, action} -> if part[xmas] > val, do: run_rule(part, [action], rules), else: run_rule(part, rest, rules)
      {:goto, new_rule} -> run_rule(part, rules[new_rule], rules)
      _ -> run_rule(part, rest, rules)
    end
  end

  def run(part, rules) do
    run_rule(part, rules["in"], rules)
  end

  def part1(input) do
    [rules, parts] = String.split(input, "\n\n")
    rules = String.split(rules, "\n", trim: true) |> Enum.map(&parse_rule/1) |> Enum.into(%{})
    String.split(parts, "\n", trim: true) |> Enum.map(&parse_part/1) |> Enum.map(fn part -> run(part, rules) end) |> Enum.sum()
  end

  def num_matches(space, [rule|rest], rules) do
    case rule do
      :accept -> Range.size(space["x"]) * Range.size(space["m"]) * Range.size(space["a"]) * Range.size(space["s"])
      :reject -> 0
      {:lt, xmas, val, action} ->
        if Range.disjoint?(space[xmas], 1..val) do
          num_matches(space, rest, rules)
        else
          num_matches(%{space | xmas => space[xmas].first..val-1}, [action], rules) +
            num_matches(%{space | xmas => val..space[xmas].last}, rest, rules)
        end
      {:gt, xmas, val, action} ->
        if Range.disjoint?(space[xmas], val..4000) do
          num_matches(space, rest, rules)
        else
          num_matches(%{space | xmas => val+1..space[xmas].last}, [action], rules) +
            num_matches(%{space | xmas => space[xmas].first..val}, rest, rules)
        end
      {:goto, new_rule} -> num_matches(space, rules[new_rule], rules)
    end
  end

  def part2(input) do
    [rules, _] = String.split(input, "\n\n")
    rules = String.split(rules, "\n", trim: true) |> Enum.map(&parse_rule/1) |> Enum.into(%{})

    num_matches(%{"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}, rules["in"], rules)
  end
end

System.argv()
|> File.read!()
|> Solution.part1()
|> IO.inspect(label: "Part 1")

System.argv()
|> File.read!()
|> Solution.part2()
|> IO.inspect(label: "Part 2")
