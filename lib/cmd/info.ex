defmodule Nerves.Cell.CLI.Cmd.Info do
  @moduledoc false

  alias Nerves.Cell.CLI.Finder

  def run(context) do
    {cell_id, cell} = 
      context
      |> Finder.discover(single: true)
      |> Map.get(:cells)
      |> List.first
    cell
    |> Enum.into([])
    |> Enum.map(fn({k,v})->[k,v] end)
    |> TableRex.quick_render!(["key", "value"], cell_id)
    |> IO.puts
  end
end
