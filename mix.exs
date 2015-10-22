defmodule Nerves.CLI.Cell.Mixfile do

  use Mix.Project

  def project do
    [app: :cell,
     escript: [main_module: Nerves.CLI.Cell, name: "cell", path: "/usr/local/bin/cell"],
     version: version,
     elixir: "~> 1.0",
     deps: deps]
  end

  def application, do: [
     applications: [:logger]
  ]

  defp deps, do: [
    {:exjsx, "~> 3.2.0" },
    {:ibrowse, github: "cmullaparthi/ibrowse", ref: "5ee4a80"},
    {:httpotion, "~> 2.1"},
    {:conform, "~> 0.17"},
    {:earmark, "~> 0.1", only: :dev},
    {:ex_doc, "~> 0.8", only: :dev}
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
