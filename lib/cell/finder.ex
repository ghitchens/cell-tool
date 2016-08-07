defmodule Nerves.CLI.Cell.Finder do

  @moduledoc """
  find cells matching cspec
  then put title with number of cells
  then run func with each cell as param
  """

  alias Nerves.CLI.Cell.SSDPClient
  require Logger

  @default_service_path "jrtp"

  @doc """
  Given a device specification `spec`, and a title, apply the function `func`
  to each of the found devices.
  """
  def apply(spec, title, func) do
    cells(spec)
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
  Attempt discovery of devices matching `cell_spec`, returning a list.
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
    |> display_cell_count(filter_spec)
  end

  # return a single cell with the specified location, because the user
  # asked for a specific cell in ip:port form.
  defp make_static_cell(cspec) do
  %{ "remote": %{ location: "http://#{cspec}/#{services_loc}", name: cspec }}
  end

  # displays count of cells, returns cells
  defp display_cell_count(cells, spec) do
    n = Enum.count(cells)
    case spec do
      nil ->
        IO.write "#{n} cells found\n"
      _ ->
        IO.write "#{n} cells found matching \"#{spec}\"\n"
    end
    cells
  end

  # return a list of cells that meet the given filter specifications
  defp filtered_discover(filter_spec) do
    SSDPClient.discover
    |> Enum.filter(&(meets_filter_spec(&1, filter_spec)))
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

  # Determines the services location path on a static cell using
  # config file if possible or using default
  defp services_loc do
    conf_path = Path.expand "~/.cell/cell.conf"
    case Conform.Parse.file(conf_path) do
      {:error, _} ->
        @default_service_path
      conf ->
        Logger.info "conf= #{inspect conf}"
        case :proplists.get_value(['cell','services_path'], conf) do
          :undefined -> @default_service_path
          st -> st
        end
    end
  end
end
