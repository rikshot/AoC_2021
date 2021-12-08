require Math

{:ok, file} = File.read("day7.txt")

positions = String.split(file, ",") |> Enum.map(&String.to_integer/1)

median = Math.Enum.median(positions)

cost = Enum.map(positions, fn position -> abs(position - median) end) |> Enum.sum()
IO.inspect(cost)

cost =
  Enum.map(Enum.min(positions)..Enum.max(positions), fn target ->
    Enum.map(positions, fn position ->
      abs = abs(position - target)
      0.5 * abs * (abs + 1)
    end)
    |> Enum.sum()
  end)
  |> Enum.min()

IO.inspect(cost)
