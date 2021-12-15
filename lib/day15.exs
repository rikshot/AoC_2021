get_neighbors = fn column, row, width, height ->
  [
    if(row == 0, do: [], else: {column, row - 1}),
    if(row == height - 1, do: [], else: {column, row + 1}),
    if(column == 0, do: [], else: {column - 1, row}),
    if(column == width - 1, do: [], else: {column + 1, row})
  ]
  |> List.flatten()
end

get_graph = fn grid, width, height, ex_width, ex_height ->
  0..(ex_height - 1)
  |> Enum.reduce(Graph.new(), fn row, graph ->
    0..(ex_width - 1)
    |> Enum.reduce(graph, fn column, graph ->
      cell = {column, row}

      get_neighbors.(column, row, ex_width, ex_height)
      |> Enum.reduce(graph, fn {column, row} = neighbor, graph ->
        weight = grid |> Enum.at(rem(row, height)) |> Enum.at(rem(column, width))
        weight = rem(weight + floor(row / height) + floor(column / width) - 1, 9) + 1

        Graph.add_edge(graph, cell, neighbor, weight: weight)
      end)
    end)
  end)
end

get_risk = fn graph, path ->
  path
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn [v1, v2] -> Graph.edge(graph, v1, v2).weight end)
  |> Enum.sum()
end

{:ok, file} = File.read("input/day15.txt")

grid =
  String.split(file, "\n")
  |> Enum.map(&String.graphemes/1)
  |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)

width = length(List.first(grid))
height = length(grid)

graph = get_graph.(grid, width, height, width, height)

Graph.Pathfinding.dijkstra(graph, {0, 0}, {width - 1, height - 1})
|> then(fn path -> get_risk.(graph, path) end)
|> IO.inspect()

ex_width = width * 5
ex_height = height * 5

graph = get_graph.(grid, width, height, ex_width, ex_height)

Graph.Pathfinding.dijkstra(graph, {0, 0}, {ex_width - 1, ex_height - 1})
|> then(fn path -> get_risk.(graph, path) end)
|> IO.inspect()

defmodule Risk do
  def calculate(grid, t) do
    pq = PriorityQueue.push(PriorityQueue.new(), {{0, 0}, 0}, 0)
    seen = MapSet.put(MapSet.new(), {0, 0})
    calculate(grid, t, pq, seen)
  end

  defp calculate(grid, t, pq, seen) do
    width = length(List.first(grid))
    height = length(grid)
    {{:value, {{x, y}, distance}}, pq} = PriorityQueue.pop(pq)

    if x == t * width - 1 and y == t * height - 1 do
      distance
    else
      {pq, seen} =
        Enum.reduce([{1, 0}, {-1, 0}, {0, 1}, {0, -1}], {pq, seen}, fn {dx, dy}, {pq, seen} ->
          neighbor = {x1, y1} = {x + dx, y + dy}

          if x1 < 0 or y1 < 0 or x1 >= t * width or y1 >= t * height do
            {pq, seen}
          else
            weight = grid |> Enum.at(rem(y1, height)) |> Enum.at(rem(x1, width))
            weight = rem(weight + floor(x1 / width) + floor(y1 / height) - 1, 9) + 1

            if !MapSet.member?(seen, neighbor) do
              {
                PriorityQueue.push(pq, {neighbor, distance + weight}, distance + weight),
                MapSet.put(seen, neighbor)
              }
            else
              {pq, seen}
            end
          end
        end)

      calculate(grid, t, pq, seen)
    end
  end
end

Risk.calculate(grid, 1) |> IO.inspect()
Risk.calculate(grid, 5) |> IO.inspect()
