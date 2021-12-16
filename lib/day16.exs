use Bitwise

{:ok, file} = File.read("input/day16.txt")
binaries = String.split(file, "\n") |> Enum.map(&Base.decode16/1)

defmodule Parser do
  def parse(binary, single \\ false)

  def parse(<<version::3, type::3, rest::bits>>, single)
      when bit_size(rest) > 1 do
    {type, {value, rest}} =
      case type do
        4 -> {:literal, parse_literal(rest, 0)}
        _ -> parse_operator(type, rest)
      end

    if single do
      {[{version, type, value}], rest}
    else
      [{version, type, value}] ++ parse(rest, false)
    end
  end

  def parse(_binary, _single) do
    []
  end

  defp parse_literal(<<last::1, value::4, rest::bits>>, literal) do
    literal = (literal <<< 4) + value

    case last do
      1 -> parse_literal(rest, literal)
      0 -> {literal, rest}
    end
  end

  defp parse_operator(type, <<length_type::1, rest::bits>>) do
    {
      case type do
        0 -> :sum
        1 -> :prod
        2 -> :min
        3 -> :max
        5 -> :gt
        6 -> :lt
        7 -> :eq
      end,
      case length_type do
        0 ->
          <<length::15, packets::bits-size(length), rest::bits>> = rest
          {parse(packets), rest}

        1 ->
          <<length::11, rest::bits>> = rest

          Enum.reduce(1..length, {[], rest}, fn _, {values, rest} ->
            {value, rest} = parse(rest, true)
            {values ++ value, rest}
          end)
      end
    }
  end
end

defmodule Analyzer do
  def get_version_sum(packets) do
    Enum.reduce(packets, 0, fn {version, type, value}, sum ->
      sum +
        case type do
          :literal -> version
          _ -> version + get_version_sum(value)
        end
    end)
  end

  def evaluate(packets) do
    Enum.map(packets, fn {_version, type, value} ->
      if type == :literal do
        value
      else
        value = evaluate(value)

        case type do
          :sum -> Enum.sum(value)
          :prod -> Enum.product(value)
          :min -> Enum.min(value)
          :max -> Enum.max(value)
          :gt -> if List.first(value) > List.last(value), do: 1, else: 0
          :lt -> if List.first(value) < List.last(value), do: 1, else: 0
          :eq -> if List.first(value) == List.last(value), do: 1, else: 0
        end
      end
    end)
  end
end

packets = Enum.map(binaries, &Parser.parse(elem(&1, 1)))

packets
|> Enum.map(fn packet ->
  Analyzer.get_version_sum(packet)
end)
|> IO.inspect()

packets
|> Enum.map(fn packet ->
  Analyzer.evaluate(packet) |> List.first()
end)
|> IO.inspect()
