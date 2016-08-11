defmodule Nerves.CLI.Cell.Finder do
  @moduledoc """
  Finds cells based on a cell query specification
  """

  alias Nerves.SSDPClient
  require Logger

  @doc """
  Given a device specification `spec`, and a title, apply the function `func`
  to each of the found devices.

  TODO: Deprecate in favor of using discover/context pattern
  """
  def apply(spec, title, func) do
    cells = discover(spec)
    case Enum.count(cells) do
      0 -> nil
      n ->
        IO.write "#{title} #{n} cell(s)\n"
        for {usn, cell} <- cells do
          func.(Dict.merge(cell, usn: usn))
        end
    end
  end

  @doc """
  Attempt discovery of devices matching `cell_spec`, returning an enumerable
  key/value list, with the key being the cell id, and all other values being
  attributes of the cell.  Return a new context with the matched cells
  """
  @spec discover(map) :: map
  def discover(context) do
    Map.put context, :cells, discover_cells(context)
  end

  # return a list of cells that meet the given filter specifications
  defp discover_cells(context) do
    [ target: context.st ]
    |> SSDPClient.discover
    |> Enum.filter(&(meets_filter_spec(&1, context[:filter])))
  end

  # decide if a cell meets the spec.  "all" and nil both match all
  # cells.  For now, only the last octet can be used otherwise
  defp meets_filter_spec(cell, spec) do
    {_key, info} = cell
    case spec do
      "all" -> true
      nil -> true
      str -> (str == info.name)
    end
  end

end
