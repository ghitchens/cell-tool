defmodule Cmd.Inspect do
  @moduledoc """
  Inspects a portion of the Hub tree provided by the cell through its JSON/HTTP
  API. This does not provide as much detail as Hub.dump/0 in the Hub modules,
  as only "public" key/value pairs are shown.

  ## Options

  The `path` parameter may be passed to specify a subtree to aquire

  ## Examples

    iex> run(".189")
    # would aquire the whole Hub tree

    iex> run(".189", "services")
    # would aquire the subtree starting a /services
  """

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(cspec, path \\ nil) do
    HTTPotion.start
    Finder.apply cspec, "Getting Hub (sub)tree ", &(get_services_doc(&1, path))
  end

  defp get_services_doc(cell, path) do
		location = cell.location
		url = case path do
      nil -> location
      p -> location<>p
    end
    IO.write "from #{url} -> "
		resp = HTTPotion.get(url)
		case resp.status_code do
			200 ->
        IO.write "ok\n"
        IO.write "#{resp.body}\n\n"
			x ->    IO.write "ERROR\n"
		end
  end
end
