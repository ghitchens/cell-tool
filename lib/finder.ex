defmodule Nerves.CLI.Cell.Finder do
  @moduledoc """
  Finds cells based on a cell query specification
  """

  alias Nerves.SSDPClient
  require Logger

  @default_service_path "jrtp"
  @default_service_type "urn:nerves-project-org:service:cell:1"

  @doc """
  Given a device specification `spec`, and a title, apply the function `func`
  to each of the found devices.
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
  attributes of the cell
  """
  @spec discover(any) :: list
  def discover(spec) do
    if :erlang.is_binary(spec) and String.length(spec) > 5 do
      make_static_cell(spec)
    else
      discovered(spec)
    end
  end

  # returns liat
  def discovered(filter_spec) do
    filtered_discover(filter_spec)
  end

  # return a single cell with the specified location, because the user
  # asked for a specific cell in ip:port form.
  defp make_static_cell(cspec) do
#  %{ "remote": %{ location: "http://#{cspec}/#{services_loc}", name: cspec }}
  end

  # return a list of cells that meet the given filter specifications
  defp filtered_discover(context) do
    [ target: context[:st] ]
    |> SSDPClient.discover
    |> Enum.filter(&(meets_filter_spec(&1, context)))
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
