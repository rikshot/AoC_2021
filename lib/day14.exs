{:ok, file} = File.read("input/day14.txt")

[template, rules] = String.split(file, "\n\n")

template =
  template
  |> String.graphemes()

rules =
  String.split(rules, "\n")
  |> Enum.map(&String.split(&1, " -> "))
  |> Enum.map(fn [pair, rule] -> {List.to_tuple(pair |> String.graphemes()), rule} end)
  |> Map.new()

count = fn template, rules, steps, limit ->
  counts = Enum.frequencies(template)

  pairs =
    template
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.frequencies()

  Enum.reduce(steps..limit, {counts, pairs}, fn _, {counts, pairs} ->
    Enum.reduce(pairs, {counts, pairs}, fn {{left, right} = pair, count}, {counts, pairs} ->
      result = rules[pair]

      {Map.update(counts, result, 1, fn value -> value + count end),
       pairs
       |> Map.update({left, result}, count, fn value -> value + count end)
       |> Map.update({result, right}, count, fn value -> value + count end)
       |> Map.update({left, right}, count, fn value -> value - count end)}
    end)
  end)
  |> elem(0)
  |> Enum.min_max_by(fn {_, value} -> value end)
  |> then(fn {{_, min}, {_, max}} -> max - min end)
end

count.(template, rules, 1, 10) |> IO.inspect()
count.(template, rules, 1, 40) |> IO.inspect()
