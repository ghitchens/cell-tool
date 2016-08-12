defmodule Nerves.Cell.CLI.Cmd.Info do
  @moduledoc false

  alias Nerves.Cell.CLI.JRTP
  alias Nerves.Cell.CLI.Finder
  alias Nerves.Cell.CLI.Inet
  alias Nerves.Cell.CLI.Render

  @doc false
  def run(context) do
    context
    |> Finder.discover_one
    |> display_info
  end

  defp display_info({cell_id, cell}) do
    cell 
    |> Enum.into([])
    |> Enum.map(fn({k,v})->[k,v] end)
    |> TableRex.quick_render!(["key", "value"], cell_id)
    |> IO.puts
  end

end
