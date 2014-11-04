defmodule Box.Mixfile do

  use Mix.Project

  def project do
    [app: :box,
     escript: [main_module: Box],
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application, do: [
     applications: [:logger]
  ]

  defp deps, do: [
		{ :exjsx, "~> 3.0.0" },
		{:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
		{:httpotion, "~> 0.2.0"}
	]

end
