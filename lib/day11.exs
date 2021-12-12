{:ok, file} = File.read("input/day11.txt")

numbers =
  String.split(file, "\n")
  |> Enum.map(&String.graphemes/1)
  |> Enum.map(&Enum.map(&1, fn char -> String.to_integer(char) end))

width = length(numbers) - 1
height = length(List.first(numbers)) - 1

numbers =
  0..height
  |> Enum.map(fn row ->
    0..width
    |> Enum.map(fn column -> {{row, column}, numbers |> Enum.at(row) |> Enum.at(column)} end)
  end)
  |> List.flatten()
  |> Map.new()

adjacent =
  Map.map(
    numbers,
    fn {{row, column} = coordinate, _} ->
      (-1..1
       |> Enum.map(fn r -> -1..1 |> Enum.map(fn c -> {row + r, column + c} end) end)
       |> List.flatten()
       |> Enum.filter(fn {row, column} ->
         row >= 0 and row <= height and column >= 0 and column <= width
       end)) -- [coordinate]
    end
  )

defmodule Octopi do
  @adjacent adjacent

  def step(numbers) do
    numbers = Map.map(numbers, fn {_, number} -> number + 1 end)
    {numbers, flashed} = flash(numbers, MapSet.new())
    {numbers, MapSet.size(flashed)}
  end

  def synchronized(numbers, n) do
    {numbers, _} = step(numbers)

    if Map.values(numbers) |> Enum.all?(fn value -> value == 0 end) do
      n
    else
      synchronized(numbers, n + 1)
    end
  end

  defp flash(numbers, flashed) do
    will_flash =
      Map.filter(numbers, fn {_, value} -> value > 9 end)
      |> Map.reject(fn {coordinate, _} -> MapSet.member?(flashed, coordinate) end)

    if map_size(will_flash) > 0 do
      flashed = MapSet.union(flashed, MapSet.new(Map.keys(will_flash)))

      flash(
        Enum.reduce(will_flash, numbers, fn {coordinate, _}, numbers ->
          Map.merge(
            Map.put(numbers, coordinate, 0),
            Map.take(numbers, @adjacent[coordinate])
            |> Map.reject(fn {coordinate, _} -> MapSet.member?(flashed, coordinate) end)
            |> Map.map(fn {_, value} -> value + 1 end)
          )
        end),
        flashed
      )
    else
      {numbers, flashed}
    end
  end
end

Enum.reduce(1..100, {numbers, 0}, fn _, {numbers, flashed} ->
  {n, f} = Octopi.step(numbers)
  {n, flashed + f}
end)
|> elem(1)
|> IO.inspect()

Octopi.synchronized(numbers, 1) |> IO.inspect()
