defmodule Nerves.CLI.Cell.Cmd.Inspect do
  @moduledoc """
  Inspects a portion of the Hub tree provided by the cell through its JSON/HTTP
  API. This does not provide as much detail as `Hub.dump/0` in the Hub modules,
  as only "public" key/value pairs are shown.

  ## Options

  The `path` parameter may be passed to specify a subtree to aquire

  ## Examples

      iex> run(".189")
      # would aquire the whole Hub tree

      iex> run(".189", "services")
      # would aquire the subtree starting a /services
  """

  alias Nerves.CLI.Cell.Finder

  @doc "Takes paramater(s) from `Cmd.main` to perform action"
  def run(cspec, path \\ nil) do
    HTTPotion.start
    table cspec, "Getting Hub (sub)tree ", &(get_services_doc(&1, path))
  end

  defp get_services_doc(cell, path) do
    url =
      cell
      |> create_url(path)

    url
    |> HTTPotion.get()
    |> verify_status()
    |> response("from #{url} -> ")
    |> IO.write()
  end

  defp create_url(cell, nil), do: cell.location
  defp create_url(cell, p), do: cell.location <> p

  defp verify_status(%HTTPotion.Response{status_code: 200, body: body}), do: "ok\n#{body}\n\n"
  defp verify_status(_), do: "ERROR\n"

  defp response(message, prefix), do: "#{prefix} #{message}"
end
