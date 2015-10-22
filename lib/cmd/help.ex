defmodule Cmd.Help do
  @moduledoc """
  Provides help and usage of the cell tool
  """

  @help """

  cell - discover, update, and debug cellulose cells

  cell list [<cells>]               list found cells (alias for discover for now)
  cell discover [<cells>]           find cells using SSDP on the LAN
  cell watch [<cells>]              watch multicast debug log of one or more cells
  cell provision <cells> <app_id>   provisions a cell to the specified type
  cell push <cells> <ware>          push specific firmware to one or more cells
  cell inspect -<cells> [<path>]    inspect a part of the Hub path
  cell normal[ize] [<cells>]        make provisional firmware normal
  cell denormal[ize] <cells>        make normal firmwae provisional
  cell reboot <cells>               reboot a cell
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

  @doc "Prints out help information using IO.write"
  def run, do: IO.write @help

end
