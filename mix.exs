defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.12",
      deps: deps()
    ]
  end

  def deps do
    [
      {:math, "~> 0.7.0"}
    ]
  end
end
