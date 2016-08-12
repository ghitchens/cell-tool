defmodule Nerves.Cell.CLI.Finder do
  @moduledoc """
  Given a command context, finds cells, resolving ambiguous references.
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
  Use SSDP to discover the devices with the search type in `context.st`,
  creating unique and useful IDs for each cell, returning an updated context
  containing all the appropriate cells.
  """
  @spec discover(map) :: map
  def discover(context) do
    cells = 
      SSDPClient.discover(target: context.st)
      |> populate_ids
      |> Enum.filter(&(meets_filter_spec(&1, context.filters)))
    Map.put context, :cells, cells
  end

  def discover_one(context) do
    result = discover(context)
    case Enum.count(result.cells) do
      1 -> 
        [cell] = result.cells
        cell
      0 -> 
        IO.puts "No matching cells"
        :erlang.halt(1)
      n -> 
        IO.puts "Matched #{n} cells -- must match only one"
        :erlang.halt(1)
    end
  end

  # choose ids for cells that are useful for humans based on data
  @spec populate_ids([{String.t, map}]) :: [{String.t, map}]
  defp populate_ids(cells) do
    Enum.map cells, fn({usn, cell}) ->
      {human_id_for(usn, cell), Map.put(cell, :usn, usn)}
    end
  end

  # given a {usn, cell}  return something short and useful
  @spec human_id_for(String.t, map) :: String.t
  defp human_id_for(_, %{cellid: cellid}=_cell) do
    if String.contains?(cellid, "-") do
      [_, boardid] = String.split(cellid, "-")
      boardid
    else
      cellid
    end
  end
  defp human_id_for(usn, _) do
    if String.contains?(usn, "::") do
        [uuid, _] = String.split(usn, "::")
    else
        uuid = usn
    end
    if String.contains?(uuid, ":") do
      [_, raw_uuid] = String.split(uuid, ":")
    else
      raw_uuid = uuid
    end
    String.slice(raw_uuid, 0..7)
    |> String.downcase
  end

  # decide if a cell meets a filter spec.  "all" and nil both match all
  # cells.  For now, only the last octet can be used otherwise
  defp meets_filter_spec(_, []), do: true
  defp meets_filter_spec(cell, spec) do
    {_key, info} = cell
    case spec do
      "all" -> true
      nil -> true
      str -> (str == info.name)
    end
  end

end
