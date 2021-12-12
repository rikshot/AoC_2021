{:ok, file} = File.read("input/day5.txt")

coordinates =
  String.split(file, "\n")
  |> Enum.map(&String.split(&1, " -> "))
  |> Enum.map(fn [start, stop] ->
    {List.to_tuple(String.split(start, ",") |> Enum.map(&String.to_integer/1)),
     List.to_tuple(String.split(stop, ",") |> Enum.map(&String.to_integer/1))}
  end)

get_grid = fn input ->
  Enum.reduce(input, %{}, fn {{x1, y1}, {x2, y2}}, grid ->
    if x1 == x2 or y1 == y2 do
      Enum.reduce(if(x1 == x2, do: y1..y2, else: x1..x2), grid, fn v, grid ->
        Map.update(grid, if(x1 == x2, do: {x1, v}, else: {v, y1}), 1, fn value -> value + 1 end)
      end)
    else
      Enum.reduce(Enum.zip([x1..x2, y1..y2]), grid, fn {x, y}, grid ->
        Map.update(grid, {x, y}, 1, fn value -> value + 1 end)
      end)
    end
  end)
end

straight_lines = Enum.filter(coordinates, fn {{x1, y1}, {x2, y2}} -> x1 == x2 or y1 == y2 end)

IO.puts(Enum.count(get_grid.(straight_lines), fn {_key, value} -> value >= 2 end))
IO.puts(Enum.count(get_grid.(coordinates), fn {_key, value} -> value >= 2 end))
