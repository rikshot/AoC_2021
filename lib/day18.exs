defmodule Snailfish do
  def add(a, b) do
    reduce("[" <> a <> "," <> b <> "]")
  end

  def magnitude(number) when is_bitstring(number) do
    {number, _} = Code.eval_string(number)
    magnitude(number)
  end

  def magnitude([a, b]) do
    3 * if(is_integer(a), do: a, else: magnitude(a)) +
      2 * if(is_integer(b), do: b, else: magnitude(b))
  end

  defp reduce(a) do
    b = explode(a)
    c = if a == b, do: split(b), else: reduce(b)
    if c == b, do: c, else: reduce(c)
  end

  defp list_to_string(a) do
    if is_list(a) do
      "[" <> (Enum.map_intersperse(a, ",", &list_to_string/1) |> Enum.join()) <> "]"
    else
      Integer.to_string(a)
    end
  end

  defp find_explode(number) do
    {number, _} = Code.eval_string(number)
    find_explode(number, 0, 0)
  end

  defp find_explode([a, b], nesting, index)
       when is_integer(a) and is_integer(b) and nesting > 3 do
    {"[" <> Integer.to_string(a) <> "," <> Integer.to_string(b) <> "]", a, b, index}
  end

  defp find_explode([a, b], nesting, index) do
    b_index = index + String.length(list_to_string(a)) + 1
    a = if !is_integer(a), do: find_explode(a, nesting + 1, index + 1), else: nil
    b = if !is_integer(b), do: find_explode(b, nesting + 1, b_index + 1), else: nil
    if a != nil, do: a, else: b
  end

  defp explode(number) do
    case find_explode(number) do
      {match, a, b, index} ->
        {left, right} = String.split_at(number, index)
        right = String.slice(right, String.length(match), String.length(right))

        left_char = Regex.run(~r/\d+/, String.reverse(left))
        right_char = Regex.run(~r/\d+/, right)

        left =
          if left_char != nil do
            left_num = String.to_integer(List.first(left_char) |> String.reverse())

            String.replace(
              String.reverse(left),
              List.first(left_char),
              String.reverse(Integer.to_string(left_num + a)),
              global: false
            )
          else
            left
          end
          |> String.reverse()

        right =
          if right_char != nil do
            right_num = String.to_integer(List.first(right_char))
            String.replace(right, right_char, Integer.to_string(right_num + b), global: false)
          else
            right
          end

        left <> "0" <> right

      _ ->
        number
    end
  end

  defp split(number) do
    case Regex.run(~r/(\d{2,})/, number) do
      [match, a] ->
        a = String.to_integer(a)
        [floor, ceil] = [floor(a / 2), ceil(a / 2)] |> Enum.map(&Integer.to_string/1)
        String.replace(number, match, "[" <> floor <> "," <> ceil <> "]", global: false)

      _ ->
        number
    end
  end
end

{:ok, file} = File.read("input/day18.txt")

numbers =
  file
  |> String.split("\n\n")
  |> Enum.map(&String.split(&1, "\n"))

numbers
|> Enum.map(fn numbers ->
  [number | rest] = numbers

  Enum.reduce(rest, number, fn b, a ->
    Snailfish.add(a, b)
  end)
  |> Snailfish.magnitude()
  |> IO.inspect()
end)

numbers
|> Enum.map(fn numbers ->
  Enum.map(for(a <- numbers, b <- numbers -- [a], do: {a, b}), fn {a, b} ->
    Snailfish.add(a, b) |> Snailfish.magnitude()
  end)
  |> Enum.max()
end)
|> IO.inspect()
