{:ok, file} = File.read("input/day6.txt")

state = String.split(file, ",") |> Enum.map(&String.to_integer/1)

defmodule Lanternfish do
  def simulate(state, 0) do
    state
  end

  def simulate(state, days) when is_list(state) do
    simulate(Enum.frequencies(state), days)
  end

  def simulate(state, days) do
    simulate(
      Enum.reduce(state, %{}, fn {day, amount}, state ->
        case day do
          0 ->
            Map.delete(state, 0)
            |> Map.merge(%{
              6 => Map.get(state, 6, 0) + amount,
              8 => Map.get(state, 8, 0) + amount
            })

          _ ->
            Map.merge(state, %{
              (day - 1) => Map.get(state, day - 1, 0) + amount
            })
        end
      end),
      days - 1
    )
  end
end

IO.puts(Enum.map(Lanternfish.simulate(state, 80), fn {_, amount} -> amount end) |> Enum.sum())
IO.puts(Enum.map(Lanternfish.simulate(state, 256), fn {_, amount} -> amount end) |> Enum.sum())
