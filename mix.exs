defmodule CellTool.Mixfile do

  use Mix.Project

  def project do
    [app: :celltool,
     escript: [main_module: CellTool, name: "cell", path: "/usr/local/bin/cell"],
     version: version,
     elixir: "~> 1.0",
     deps: deps]
  end

  def application, do: [
     applications: [:logger]
  ]

  defp deps, do: [
                {:earmark, "~> 0.1", only: :dev},
                {:ex_doc, "~> 0.7", only: :dev},
		{:exjsx, "~> 3.0.0" },
		{:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
		{:httpotion, "~> 0.2.4"},
                {:conform, github: "bitwalker/conform"}
	]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
