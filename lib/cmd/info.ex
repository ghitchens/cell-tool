defmodule Nerves.Cell.CLI.Cmd.Info do
  @moduledoc false

  alias Nerves.CLI.Cell.JRTP
  alias Nerves.CLI.Cell.Finder
  alias Nerves.CLI.Cell.Inet
  alias Nerves.CLI.Cell.Render

  @doc false
  def run(context) do
    context
    |> Finder.discover
    |> Map.get(:cells)
    |> Enum.each fn({usn, cell}) ->
         IO.puts "#{usn}"
         Enum.each cell, fn({k,v}) ->
           IO.puts "\t#{k}: #{v}"
         end
         IO.puts ""
       end
  end
end
