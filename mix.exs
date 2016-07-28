defmodule Nerves.CLI.Cell.Mixfile do

  use Mix.Project

  @version "0.2.3"

  def project do
    [app: :cell,
     description: "Utility for managing nerves devices",
     escript: [main_module: Nerves.CLI.Cell, name: "cell", path: "/usr/local/bin/cell"],
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     # Hex
     package: package,
     # ExDoc
     name: "Cell",
     docs: [main: Nerves.CLI.Cell,
            source_url: "https://github.com/nerves-project/cell-tool",
            extras: ["README.md"]]]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:exjsx, "~> 3.2" },
     {:httpotion, "~> 3.0"},
     {:conform, "~> 0.17"},
     {:ex_doc, "~> 0.13", only: [:dev, :docs]}]
  end

  def package do
    [ maintainers: ["Garth Hitchens"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nerves-project/cell-tool"} ]
  end

end
