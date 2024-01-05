
defmodule FlipFlop do
  defstruct [:name, state: false, outputs: []]
end

defmodule Nand do
  defstruct [:name, inputs: %{}, outputs: []]
end

defmodule Broadcaster do
  defstruct [:name, outputs: []]
end

defmodule Receiver do
  defstruct [:name, triggered: false, outputs: []]
end

defmodule Solution do
  def parse_rule(line) do
    cond do
      (match = Regex.run(~r/%(\w+) -> (.*)$/, line)) ->
        [_, name, outputs] = match
        {name, {:flipflop, String.split(outputs, ", ", trim: true)}}
      (match = Regex.run(~r/&(\w+) -> (.*)$/, line)) ->
        [_, name, outputs] = match
        {name, {:nand, String.split(outputs, ", ", trim: true)}}
      (match = Regex.run(~r/broadcaster -> (.*)$/, line)) ->
        [_, outputs] = match
        {"broadcaster", {:broadcast, String.split(outputs, ", ", trim: true)}}
    end
  end

  def recv(_sender, %Broadcaster{} = broadcaster, signal) do
    {broadcaster, signal}
  end

  def recv(sender, %Nand{inputs: inputs} = nand, signal) do
    new_state = %{nand | inputs: %{inputs | sender => signal}}
    if Enum.all?(new_state.inputs, fn {_, state} -> state end) do
      {new_state, false}
    else
      {new_state, true}
    end
  end

  def recv(_sender, %FlipFlop{state: old_state} = flipflop, signal) do
    if signal do
      {flipflop, nil}
    else
      {%{flipflop | state: !old_state}, !old_state}
    end
  end

  def recv(_sender, %Receiver{} = receiver, signal) do
    new_state = if !signal do
      %{receiver | triggered: true}
    else
      receiver
    end
    {new_state, nil}
  end

  def run(_state, []), do: []
  def run(state, [{sender, dest, type}|rest]) do
    part = state[dest]
    if part == nil do
      [{type, state} | run(state, rest)]
    else
      {new, signal} = recv(sender, part, type)
      new_signals = if signal != nil do
        for output <- part.outputs, do: {dest, output, signal}
      else
        []
      end
      new_state = %{state | dest => new}
      [{type, new_state} | run(new_state, rest ++ new_signals)]
    end
  end

  def run(state) do
    results = run(state, [{nil, "broadcaster", false}])
    {results |> Enum.map(fn {type, _state} -> type end), elem(List.last(results), 1)}
  end

  def parse_input(input) do
    parts = String.split(input, "\n", trim: true)
            |> Enum.map(&parse_rule/1)
            |> Enum.into(%{})
    for {name, {_, outputs}} <- parts,
      output <- outputs,
      match?({:nand, _}, parts[output]) do
        {output, name}
      end
      |> Enum.group_by(fn {output, _} -> output end, fn {_, input} -> input end)
      |> Enum.map(fn {name, inputs} -> {name, %Nand{name: name, inputs: for(input <- inputs, into: %{}, do: {input, false}), outputs: elem(parts[name], 1)}} end)
      |> Enum.into(%{})
      |> Map.merge(for({name, part} <- parts, match?({:flipflop, _}, part), into: %{}, do: {name, %FlipFlop{name: name, outputs: elem(parts[name], 1)}}))
      |> Map.merge(%{"broadcaster" =>  %Broadcaster{name: "broadcaster", outputs: elem(parts["broadcaster"], 1)}})
  end

  def part1(state) do
    pulses = Stream.unfold({%{}, 0, state}, fn {map, n, s} ->
      {signals, next_s} = run(s)
      if Map.has_key?(map, next_s) do
        nil
      else
        {signals, {Map.put(map, next_s, n+1), n+1, next_s}}
      end
    end)
    |> Stream.take(1000)
    |> Enum.to_list()

    num_cycles = div(1000, length(pulses))
    high_pulses = Enum.count(Enum.concat(pulses), fn t -> t end) * num_cycles
    low_pulses = Enum.count(Enum.concat(pulses)) * num_cycles - high_pulses
    high_pulses * low_pulses
  end

  def stream_length(stream) do
    stream |>
    Stream.concat([:end])
    |> Stream.transform(0, fn i, acc -> if i == :end, do: {[acc], acc}, else: {[], acc + 1} end)
    |> Enum.into([])
    |> List.first()
  end

  def get_period(state, module) do
    Stream.unfold(Map.put(state, module, %Receiver{name: module}), fn s ->
      {_, next_s} = run(s)
      {next_s, %{next_s | module => %{next_s[module] | triggered: false}}}
    end)
    |> Stream.with_index()
    |> Stream.filter(fn {s, _} -> s[module].triggered end)
    |> Stream.map(fn {_, n} -> n end)
    |> Stream.take(2)
    |> Enum.to_list()
    |> then(fn [a, b] -> b - a end)
  end

  def part2(state) do
    output_node = Enum.filter(state, fn {_, s} -> "rx" in s.outputs end)
                  |> Enum.map(fn {node, _} -> node end)
                  |> List.first()
    Enum.filter(state, fn {_, s} -> output_node in s.outputs end)
    |> Enum.map(fn {node, _} -> get_period(state, node) end)
    |> Enum.product()
  end
end

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part1()
|> IO.inspect()

System.argv()
|> File.read!()
|> Solution.parse_input()
|> Solution.part2()
|> IO.inspect()
