defmodule Nerves.Cell.CLI.Cmd.List do
  @moduledoc """
  Discovers cells on the local network and displays key information such as
  the last octet of their IP, serial number, device type and firmware version.
  """

  alias Nerves.Cell.CLI.Finder
  alias Nerves.Cell.CLI.Render

  @doc false
  def run(context) do
    context
    |> Finder.discover
    |> Render.table([:id, :host, :platform, :target, :version, :server])
    |> IO.puts
  end
end

