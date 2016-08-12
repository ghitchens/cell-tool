defmodule Nerves.Cell.CLI.Cmd.Help do
  @moduledoc false

  @global_help ~S"""
  Manages one or more Nerves "Cells" on a network

  Commands:
    cell list             # Show cells on the local network
    cell info <cell>      # Show detailed information about a cell 
    cell push             # Push a specific firmware to a cell 
    cell watch            # Watch log of local cells on a network
    cell reboot           # Restart a cell
    cell help [topic]     # Prints help information for commands or options

  Options:
    -h, --help            # alias for `cell help`
    -v, --version         # Print version of `cell` tool
    -t, --type <type>     # limit search/ops to specific service type
  """

  def run %{args: []} do
    IO.puts @global_help
  end
end
