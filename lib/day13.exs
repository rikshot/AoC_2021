{:ok, file} = File.read("input/day13.txt")

[coords, folds] = String.split(file, "\n\n")

{coords, folds} =
  {String.split(coords, "\n")
   |> Enum.map(fn row ->
     String.split(row, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
   end)
   |> MapSet.new(),
   String.split(folds, "\n")
   |> Enum.map(fn row ->
     [axis, value] = String.split(row, "fold along ") |> List.last() |> String.split("=")
     {String.to_atom(axis), String.to_integer(value)}
   end)}

do_folds = fn coords, folds ->
  Enum.reduce(folds, coords, fn {axis, value}, coords ->
    case axis do
      :y ->
        folded = Enum.filter(coords, fn {_x, y} -> y > value end)

        MapSet.union(
          MapSet.difference(coords, MapSet.new(folded)),
          MapSet.new(folded |> Enum.map(fn {x, y} -> {x, value - (y - value)} end))
        )

      :x ->
        folded = Enum.filter(coords, fn {x, _y} -> x > value end)

        MapSet.union(
          MapSet.difference(coords, MapSet.new(folded)),
          MapSet.new(folded |> Enum.map(fn {x, y} -> {value - (x - value), y} end))
        )
    end
  end)
end

do_folds.(coords, Enum.take(folds, 1)) |> Enum.count() |> IO.inspect()

output = do_folds.(coords, folds)
width = Enum.max_by(output, &elem(&1, 0)) |> elem(0)
height = Enum.max_by(output, &elem(&1, 1)) |> elem(1)

0..height
|> Enum.map(fn row ->
  0..width
  |> Enum.map(fn column ->
    if MapSet.member?(output, {column, row}), do: IO.write("#"), else: IO.write(" ")
  end)

  IO.write("\n")
end)
