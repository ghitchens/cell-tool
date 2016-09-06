defmodule Nerves.Cell.CLI.Cmd.List do
  @moduledoc """
  Discovers cells on the Local network and displays key information such as
  the last octet of their IP, serial number, device type and firmware version.
  """

  alias Nerves.Cell.CLI.Finder
  alias Nerves.Cell.CLI.Render

  @doc false
  def run(context) do
    context
    |> Finder.discover
    |> Render.table([:id, :host, :version, :server, :location])
    |> IO.puts
  end
end
