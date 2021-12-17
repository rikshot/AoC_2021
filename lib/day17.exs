{:ok, file} = File.read("input/day17.txt")

{x_range, y_range} =
  file
  |> String.replace("target area: ", "")
  |> String.split(", ")
  |> Enum.zip(["x=", "y="])
  |> Enum.map(fn {range, label} ->
    range
    |> String.replace(label, "")
    |> String.split("..")
    |> Enum.map(&String.to_integer/1)
    |> then(fn [start, finish] -> Range.new(start, finish) end)
  end)
  |> List.to_tuple()

defmodule Probe do
  @x_range x_range
  @y_range y_range

  def shoot({dx, dy}, {px, py} \\ {0, 0}, height \\ 0) do
    {_px, py} = position = {px + dx, py + dy}
    height = if py > height, do: py, else: height

    cond do
      in_target_range(position) ->
        {true, height}

      beyond_target_range(position) ->
        {false, height}

      true ->
        dx = if dx > 0, do: dx - 1, else: if(dx < 0, do: dx + 1, else: dx)
        dy = dy - 1
        shoot({dx, dy}, position, height)
    end
  end

  def search_highest() do
    Enum.reduce(for(x <- 0..1000, y <- -500..500, do: {x, y}), 0, fn {dx, dy}, height ->
      case shoot({dx, dy}) do
        {true, new_height} -> if(new_height > height, do: new_height, else: height)
        _ -> height
      end
    end)
  end

  def search_all() do
    Enum.reduce(for(x <- 0..1000, y <- -500..500, do: {x, y}), [], fn {dx, dy}, list ->
      case shoot({dx, dy}) do
        {true, _} -> [{dx, dy} | list]
        _ -> list
      end
    end)
  end

  defp in_target_range({px, py}) do
    Enum.member?(@x_range, px) and Enum.member?(@y_range, py)
  end

  defp beyond_target_range({px, py}) do
    px > Enum.max(@x_range) or py < Enum.min(@y_range)
  end
end

Probe.search_highest() |> IO.inspect()
Probe.search_all() |> Enum.count() |> IO.inspect()
