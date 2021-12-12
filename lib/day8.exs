{:ok, file} = File.read("input/day8.txt")

input =
  String.split(file, "\n")
  |> Enum.map(&String.split(&1, " | "))
  |> Enum.map(fn [input, output] -> {String.split(input), String.split(output)} end)

count =
  Enum.reduce(input, 0, fn {_, output}, acc ->
    acc + Enum.count(output, fn output -> Enum.member?([2, 3, 4, 7], String.length(output)) end)
  end)

IO.inspect(count)

find_chars = fn input, chars ->
  Enum.all?(String.graphemes(chars), fn char -> String.contains?(input, char) end)
end

count =
  Enum.map(input, fn {input, output} ->
    eight = Enum.find(input, &(String.length(&1) == 7))
    seven = Enum.find(input, &(String.length(&1) == 3))
    four = Enum.find(input, &(String.length(&1) == 4))
    one = Enum.find(input, &(String.length(&1) == 2))
    fives = Enum.filter(input, &(String.length(&1) == 5))
    sixes = Enum.filter(input, &(String.length(&1) == 6))
    nine = Enum.find(sixes, &find_chars.(&1, four))
    zero = Enum.find(sixes -- [nine], &find_chars.(&1, seven))
    [six] = (sixes -- [nine]) -- [zero]
    three = Enum.find(fives, &find_chars.(&1, seven))

    five =
      Enum.find(fives -- [three], fn five ->
        length(String.graphemes(five) -- String.graphemes(six)) == 0
      end)

    [two] = (fives -- [five]) -- [three]

    map = %{
      zero => "0",
      one => "1",
      two => "2",
      three => "3",
      four => "4",
      five => "5",
      six => "6",
      seven => "7",
      eight => "8",
      nine => "9"
    }

    Enum.map(output, fn output ->
      map[
        Enum.find(Map.keys(map), fn key ->
          String.length(key) == String.length(output) and find_chars.(key, output)
        end)
      ]
    end)
    |> Enum.join()
    |> String.to_integer()
  end)

IO.inspect(count |> Enum.sum())
