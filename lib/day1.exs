{:ok, input} = File.read("day1.txt")
numbers = String.split(input, "\n") |> Enum.map(&String.to_integer/1)

Enum.chunk_every(numbers, 2, 1, :discard)
|> Enum.reduce(0, fn [a, b], acc ->
  if b > a, do: acc + 1, else: acc
end)
|> IO.puts()

Enum.chunk_every(numbers, 3, 1, :discard)
|> Enum.map(&Enum.sum/1)
|> Enum.chunk_every(2, 1, :discard)
|> Enum.reduce(0, fn [a, b], acc ->
  if b > a, do: acc + 1, else: acc
end)
|> IO.puts()
