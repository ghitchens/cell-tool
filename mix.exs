defmodule Nerves.Cell.CLI.Mixfile do

  use Mix.Project

  @version "0.3.0-dev"

  def project do
    [app: :cell,
     description: "Utility for managing nerves devices",
     escript: [main_module: Nerves.Cell.CLI,
               name: "cell",
               path: "/usr/local/bin/cell"],
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     # Hex
     package: package,
     # ExDoc
     name: "Cell",
     docs: [main: Nerves.Cell.CLI,
            source_url: "https://github.com/nerves-project/cell-tool",
            extras: ["README.md"]]]
  end

  def application do
    [applications: [:logger, :table_rex]]
  end

  defp deps do
    [{:exjsx, "~> 3.2" },
     {:httpotion, "~> 3.0"},
     {:table_rex, "~> 0.8.1"},
     {:conform, "~> 0.17"},
     {:nerves_ssdp_client, "~> 0.1"},
     {:ex_doc, "~> 0.13", only: [:dev, :docs]}]
  end

  def package do
    [ maintainers: ["Garth Hitchens"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nerves-project/cell-tool"} ]
  end

end
