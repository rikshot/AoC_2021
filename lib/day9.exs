{:ok, file} = File.read("day9.txt")

defmodule Grid do
  @grid String.split(file, "\n")
        |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&String.to_integer/1) end)
  @width length(List.first(@grid)) - 1
  @height length(@grid) - 1

  def adjacent(row, column) do
    top = if row == 0, do: [], else: {row - 1, column, Enum.at(@grid, row - 1) |> Enum.at(column)}

    left =
      if column == 0, do: [], else: {row, column - 1, Enum.at(@grid, row) |> Enum.at(column - 1)}

    right =
      if column == @width,
        do: [],
        else: {row, column + 1, Enum.at(@grid, row) |> Enum.at(column + 1)}

    bottom =
      if row == @height,
        do: [],
        else: {row + 1, column, Enum.at(@grid, row + 1) |> Enum.at(column)}

    [top, left, right, bottom] |> List.flatten()
  end

  def low_points() do
    coordinates =
      0..@height
      |> Enum.map(fn row -> 0..@width |> Enum.map(fn column -> {row, column} end) end)
      |> List.flatten()

    Enum.map(coordinates, fn {row, column} ->
      cell = Enum.at(@grid, row) |> Enum.at(column)
      adjacent = adjacent(row, column)
      if Enum.all?(adjacent, &(cell < elem(&1, 2))), do: {row, column, cell}, else: nil
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def basin({row, column, cell}, acc) do
    adjacent =
      adjacent(row, column)
      |> Enum.filter(fn {_row, _column, adjacent_cell} ->
        adjacent_cell > cell and adjacent_cell < 9
      end)

    (acc ++ [{row, column, cell}] ++ Enum.map(adjacent, &basin(&1, acc)))
    |> List.flatten()
    |> Enum.uniq()
  end
end

Grid.low_points() |> Enum.map(&(elem(&1, 2) + 1)) |> Enum.sum() |> IO.inspect()

Grid.low_points()
|> Enum.map(&Grid.basin(&1, []))
|> Enum.map(&length(&1))
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.product()
|> IO.inspect()
