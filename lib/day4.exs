{:ok, file} = File.read("day4.txt")
[raw_numbers | raw_boards] = String.split(file, "\n\n")
numbers = String.split(raw_numbers, ",") |> Enum.map(&String.to_integer/1)

boards =
  Enum.map(raw_boards, fn raw_board ->
    String.split(raw_board, "\n")
    |> Enum.map(&String.split/1)
    |> List.flatten()
    |> Enum.map(fn number -> {String.to_integer(number), false} end)
  end)

defmodule Bingo do
  def draw([number | numbers], boards) do
    marked_boards = Enum.map(boards, fn board -> mark_board(number, board) end)

    case Enum.find(marked_boards, &check_board/1) do
      nil -> draw(numbers, marked_boards)
      board -> {number, board}
    end
  end

  def last([number | numbers], boards) do
    marked_boards = Enum.map(boards, fn board -> mark_board(number, board) end)
    incomplete_boards = Enum.filter(boards, &(!check_board(&1)))

    case incomplete_boards do
      [_board] -> draw(numbers, incomplete_boards)
      _ -> last(numbers, marked_boards)
    end
  end

  defp mark_board(drawn_number, board) do
    Enum.map(board, fn {number, marked} ->
      if drawn_number == number, do: {number, true}, else: {number, marked}
    end)
  end

  defp check_board(board) do
    Enum.any?(0..4, fn row ->
      Enum.all?(0..4, fn column -> elem(Enum.at(board, row * 5 + column), 1) end)
    end) or
      Enum.any?(0..4, fn column ->
        Enum.all?(0..4, fn row -> elem(Enum.at(board, row * 5 + column), 1) end)
      end)
  end
end

{number, board} = Bingo.draw(numbers, boards)

get_sum = fn board ->
  Enum.filter(board, fn {_, marked} -> !marked end)
  |> Enum.map(fn {number, _} -> number end)
  |> Enum.sum()
end

IO.puts(get_sum.(board) * number)

{number, board} = Bingo.last(numbers, boards)

IO.puts(get_sum.(board) * number)
