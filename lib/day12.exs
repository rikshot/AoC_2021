{:ok, file} = File.read("input/day12.txt")

edges =
  String.split(file, "\n") |> Enum.map(fn row -> String.split(row, "-") |> List.to_tuple() end)

graph =
  Enum.reduce(edges, Graph.new(), fn {a, b}, graph ->
    Graph.add_edges(graph, [{a, b}, {b, a}])
  end)

defmodule Paths do
  def find(graph, current, visited, double) do
    visited =
      if current =~ ~r/[a-z]+/ do
        MapSet.put(visited, current)
      else
        visited
      end

    Enum.reduce(Graph.neighbors(graph, current), 0, fn neighbor, num_paths ->
      if neighbor == "end" do
        num_paths + 1
      else
        if neighbor != "start" do
          if !MapSet.member?(visited, neighbor) do
            num_paths + find(graph, neighbor, visited, double)
          else
            if !double do
              num_paths + find(graph, neighbor, visited, true)
            else
              num_paths
            end
          end
        else
          num_paths
        end
      end
    end)
  end
end

Paths.find(graph, "start", MapSet.new(), true) |> IO.inspect()
Paths.find(graph, "start", MapSet.new(), false) |> IO.inspect()
