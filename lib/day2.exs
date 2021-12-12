{:ok, input} = File.read("input/day2.txt")

commands =
  String.split(input, "\n")
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [command, param] -> {command, String.to_integer(param)} end)

{position, depth} =
  Enum.reduce(commands, {0, 0}, fn command, {position, depth} ->
    case command do
      {"forward", param} -> {position + param, depth}
      {"down", param} -> {position, depth + param}
      {"up", param} -> {position, depth - param}
    end
  end)

IO.puts(position * depth)

{position, depth, _aim} =
  Enum.reduce(commands, {0, 0, 0}, fn command, {position, depth, aim} ->
    case command do
      {"forward", param} -> {position + param, depth + aim * param, aim}
      {"down", param} -> {position, depth, aim + param}
      {"up", param} -> {position, depth, aim - param}
    end
  end)

IO.puts(position * depth)
