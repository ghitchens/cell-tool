defmodule CellTool.Mixfile do

  use Mix.Project

  def project do
    [app: :celltool,
     escript: [main_module: Main, name: "cell", path: "/usr/local/bin/cell"],
     version: "0.1.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application, do: [
     applications: [:logger]
  ]

  defp deps, do: [
		{:exjsx, "~> 3.0.0" },
		{:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
		{:httpotion, "~> 0.2.4"}
	]

end
