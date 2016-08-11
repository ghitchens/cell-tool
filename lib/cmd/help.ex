defmodule Nerves.Cell.CLI.Cmd.Help do
  @moduledoc false

  @help """

  cell - discover, update, and debug nerves cells

  cell list [<cells>]               Summarize cells on a local network
  cell push <cells> <firmware>      Push specific firmware to a cell
  cell watch [<cells>]              watch multicast debug log of one or more cells
  cell reboot <cells>               reboot a cell
  cell info <cell>                  Read extended information about a cell

  cell [--version]                  show version for this program
  cell [--help]                     shows this help message


  Options:

    <cells>
          Specifies cell(s) to operate on, in one of the following formats:

          .nnn                    Last octet of the IP on the LAN in decimal

    <ware>
          Specifies the firmware (including path) to install, in one of the
          following formats:

          build/test.fw           Path to firmware in the filesystem

    <path>
          Specifies a path in the Hub tree to view, in the following formats:

          services

          services/firmware

          path/to/somewhere[/...]

    <app_id>
          Specifies the application ID to provision the cell to. Executes the
          method activate/2 found in ~/.cell/provision/<app_id>.ex, written for
          your particular needs. The return of this function is HTTP PUT to the
          device at the location returned by Finder plus /sys/firmware.

          The format of the <app_id> is to be one word or words joined by a '_'

          cr1a

          test_cell
  """

  def run(context) do
    IO.write @help
  end

end
