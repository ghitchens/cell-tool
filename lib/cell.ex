defmodule Nerves.CLI.Cell do
  @moduledoc """
  A simple command line interface for managing cells built using modules from the [Cellulose](cellulose.io) projects.

  **Note:** All functions may not be usable with all cells. Since, all cells may not implement all modules offered by the Cellulose Project.

  ## Configuration Example

  Runtime configuration is possible by placing a file at `~/.cell/cell.conf` with
  the following format:

  ```bash
  # Service Type for Cell tool to use in M-SEARCH
  # Default: "urn:cellulose-io:serivce:cell:1"
  cell.ssdp_st = "urn:mydomain-com:service:audio:1"

  # Services Doc location relative to base path
  # Default: "jrtp"
  cell.services_path = "cell"
  ```

  ## Examples

      $ cell list
      1 cells found
      NAME	SERIAL#		TYPE	VERSION - 1 cell(s)
      .172	CP1-xxxxx	CP1	  1.1.1

      $ cell list -c .168
      0 cells found matching ".168"

      $ cell push -c .168 -f _images/firmware.fw
      Pushing '_images/firmwmare.fw' to ".168"
      cell: /jrtp/sys/firmware/current -> ok
  """
  alias Nerves.CLI.Cell.Cmd
  
  @cell_tool_version Mix.Project.config[:version]

  @doc "Function that gets call when run as CLI"
  def main(args) do
    args
      |> parse_args
  end

  # Parses the argument list and calls the appropirate module
  defp parse_args(args) do
    options = OptionParser.parse args, [aliases: aliases]

    case options do
      #Normalize
      {[], ["normal"], []} -> Cmd.Normalize.run(nil)
      {[], ["normal", cells], []} -> Cmd.Normalize.run(cells)
      {[], ["normalize"], []} -> Cmd.Normalize.run(nil)
      {[], ["normalize", cells], []} -> Cmd.Normalize.run(cells)
      #Denormalize
      {[], ["denormal", cells], []} -> Cmd.Denormalize.run(cells)
      {[], ["denormalize", cells], []} -> Cmd.Denormalize.run(cells)
      #Discover
      {[], ["discover"], []} -> Cmd.Discover.run(nil)
      {[], ["discover", cells], []} -> Cmd.Discover.run(cells)
      {[], ["list"], []} -> Cmd.Discover.run(nil)
      {[], ["list", cells], []} -> Cmd.Discover.run(cells)
      #Provision
      {[], ["provision", cells, app_id], []} -> Cmd.Provision.run(cells, app_id)
      {args, ["provision", cells, app_id], []} -> Cmd.Provision.run(cells, app_id, argv_to_dict(args[:options]))
      #Push
      {[], ["push", cells, fw], []} -> Cmd.Push.run(fw, cells)
      #Watch
      {[], ["watch"], []} -> Cmd.Watch.run
      {[], ["watch", cells], []} -> Cmd.Watch.run(cells)
      #Reboot
      {[], ["reboot", cells], []} -> Cmd.Reboot.run(cells)
      #Inspect Hub
      {[], ["inspect", cells], []} -> Cmd.Inspect.run(cells)
      {[], ["inspect", cells, path], []} -> Cmd.Inspect.run(cells, path)
      # IP
      # {[cells: cells, ip: ip, mask: mask, router: router], ["static"], []} ->
      #   Cmd.Ip.run(cells, ip, mask, router)
      #Help
      {[], ["help"], _} -> Cmd.Help.run
      {[help: true], _, _} -> Cmd.Help.run
      #Version
      {[], ["version"], _} -> IO.write "cell v#{@cell_tool_version}"
      {[version: true], _, _} -> IO.write "cell v#{@cell_tool_version}"
      #Default
      _ ->
        IO.write "Invalid usage or malformed command\n\nUsage:\n\n"
        Cmd.Help.run
    end
  end

  # definition of aliases to be used with OptionParser
  defp aliases, do: [h: :help, v: :version, o: :options]
  
  # captchrisd - utiltity for provision argument breakdown - REVIEW
  defp argv_to_dict(args) do
    args = String.split(args, ",")
    {args, _} = Enum.flat_map_reduce(args, [], fn(x, acc) -> 
      case String.split(x, "=") do
        [k, v] -> {["#{k}": v], acc}
        _ -> {:halt, acc}
      end
    end)
    args
  end
  
end
