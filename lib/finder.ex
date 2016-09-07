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
#    Logger.debug "Discovering target #{context.st} args {context.filters}"
    cells =
      SSDPClient.discover(target: context.st)
      |> normalize_keys_and_ids
      |> Enum.filter(&(meets_filter_spec(&1, context)))
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

  # remove x- from ssdp header keys, providing in downcase form, and
  # move the usn from the key in the cell into the map itself, replacing
  # the key with a true cell ID
  @spec normalize_keys_and_ids([{String.t, map}]) :: [{String.t, map}]
  defp normalize_keys_and_ids(cells) do
    Enum.map cells, fn({usn, cell}) ->
      new_cell =
        cell
        |> normalize_cell
        |> Map.put(:usn, usn)
      {id_for(usn, cell), new_cell}
    end
  end

  @spec normalize_cell(map) :: map
  defp normalize_cell(cell) do
    cell
    |> Enum.map(fn({k, v}) -> {normalize_key(k), v} end)
    |> Enum.into(%{})
  end

  # remove x- from front of keys, and convert them to lowercase atoms
  @spec normalize_key(atom) :: atom
  defp normalize_key(atom_key) do
    atom_key
    |> to_string
    |> String.downcase
    |> case do
      <<"x-", s::binary>> ->
        s
      other ->
        other
    end
    |> String.to_atom
  end

  # given a {usn, cell}  return a useful unique ID for the cell
  @spec id_for(String.t, map) :: String.t
  defp id_for(_, %{id: id}=_cell), do: id
  defp id_for(usn, _) do
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

  # decide if a cell meets a filter spec.
  # For now, only the node is used to match
  defp meets_filter_spec(_, []), do: true
  defp meets_filter_spec({key, _cell}, context) do
#    Logger.debug "filtering on #{inspect context.args} with key #{key}"
    context.args
    |> List.first
    |> case do
      nil -> true
      ^key -> true
      "all" -> true
      _ -> false
    end
  end

end
