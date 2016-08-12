defmodule Nerves.Cell.CLI.Finder do
  @moduledoc """
  Given a command context, finds cells, resolving ambiguous references.
  """

  alias Nerves.SSDPClient
  require Logger

  @doc """
  Use SSDP to discover the devices with the search type in `context.st`,
  creating unique and useful IDs for each cell, returning an updated context
  containing all the appropriate cells.

  Options:    
  
    single: true
  """
  @spec discover(map, Keyword.T) :: map
  def discover(context, options \\ []) do
    cells = 
      SSDPClient.discover(target: context.st)
      |> populate_ids
      |> Enum.filter(&(meets_filter_spec(&1, context.filters)))
    count = Enum.count(cells)
    cells = case {options[:single], count} do
      {true, 1} -> cells
      {nil, _} -> cells
      {_, 0} ->
        IO.puts "No matching cells"
        :erlang.halt(1)
      {true, n} -> 
        IO.puts "Matched #{n} cells -- must match only one"
        :erlang.halt(1)
    end
    Map.put context, :cells, cells
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
    uuid = if String.contains?(usn, "::") do
        String.split(usn, "::")
        |> List.first
    else
        usn
    end
    if String.contains?(uuid, ":") do
      [_, raw_uuid] = String.split(uuid, ":")
      raw_uuid
    else
      uuid
    end
    |> String.slice(0..7)
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
