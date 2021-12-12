{:ok, input} = File.read("input/day3.txt")
numbers = String.split(input, "\n")

defmodule Ratings do
  def count_digits(columns, column) do
    c = Enum.at(columns, column)
    {Enum.count(c, fn digit -> digit == "1" end), Enum.count(c, fn digit -> digit == "0" end)}
  end

  def get_columns(input) do
    length = String.length(List.first(input))

    for p <- 0..(length - 1),
        do:
          Enum.reduce(input, "", fn number, acc ->
            acc <> String.at(number, p)
          end)
          |> String.graphemes()
  end

  def oxygen([number], _column) do
    String.to_integer(number, 2)
  end

  def oxygen(input, column) do
    columns = get_columns(input)
    {ones, zeros} = count_digits(columns, column)

    oxygen(
      Enum.filter(input, fn number ->
        Enum.at(String.graphemes(number), column) ==
          if ones >= zeros, do: "1", else: "0"
      end),
      column + 1
    )
  end

  def co2([number], _column) do
    String.to_integer(number, 2)
  end

  def co2(input, column) do
    columns = get_columns(input)
    {ones, zeros} = count_digits(columns, column)

    co2(
      Enum.filter(input, fn number ->
        Enum.at(String.graphemes(number), column) ==
          if ones >= zeros, do: "0", else: "1"
      end),
      column + 1
    )
  end
end

columns = Ratings.get_columns(numbers)

counts =
  0..(length(columns) - 1) |> Enum.map(fn column -> Ratings.count_digits(columns, column) end)

gamma =
  counts
  |> Enum.map(fn {ones, zeros} -> if ones > zeros, do: "1", else: "0" end)
  |> Enum.join()
  |> String.to_integer(2)

epsilon =
  counts
  |> Enum.map(fn {ones, zeros} -> if ones > zeros, do: "0", else: "1" end)
  |> Enum.join()
  |> String.to_integer(2)

IO.puts(gamma * epsilon)

IO.puts(Ratings.oxygen(numbers, 0) * Ratings.co2(numbers, 0))
