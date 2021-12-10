{:ok, file} = File.read("day10.txt")
lines = String.split(file, "\n")

defmodule Parser do
  @chunks %{"(" => ")", "[" => "]", "{" => "}", "<" => ">"}

  def parse(line, index, chunks) when chunks == nil or length(chunks) == 0 do
    parse(line, index + 1, [String.at(line, index)])
  end

  def parse(line, index, [chunk | chunks]) do
    char = String.at(line, index)

    cond do
      index >= String.length(line) -> [chunk | chunks]
      @chunks[chunk] == char -> parse(line, index + 1, chunks)
      Enum.member?(Map.keys(@chunks), char) -> parse(line, index + 1, [char, chunk | chunks])
      true -> {index, chunk, char}
    end
  end

  def complete(chunks) do
    Enum.map(chunks, &@chunks[&1])
  end
end

points = %{")" => 3, "]" => 57, "}" => 1197, ">" => 25137}

Enum.map(lines, &Parser.parse(&1, 0, nil))
|> Enum.filter(&(!is_list(&1)))
|> Enum.map(&points[elem(&1, 2)])
|> Enum.sum()
|> IO.inspect()

points = %{")" => 1, "]" => 2, "}" => 3, ">" => 4}

values =
  Enum.map(lines, &Parser.parse(&1, 0, nil))
  |> Enum.filter(&is_list(&1))
  |> Enum.map(&Parser.complete/1)
  |> Enum.map(
    &Enum.reduce(&1, 0, fn char, acc ->
      acc * 5 + points[char]
    end)
  )
  |> Enum.sort()

IO.inspect(Enum.at(values, floor(length(values) / 2)))
