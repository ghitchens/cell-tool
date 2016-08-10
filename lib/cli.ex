defmodule Nerves.Cell.CLI do
  @moduledoc """
  A CLI for managing Nerves devices that implement the "Cell" protocol set.  For
  more information see nerves_cell.

  Because not all cells implement all optional Cell features, not all functions
  may be usable with all cells.

  ## Configuration Example

  Runtime configuration is possible by placing a file at `~/.cell/cell.conf`
  with the following format:

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
  require Logger

  @cell_tool_version Mix.Project.config[:version]
  @default_st "urn:nerves-project-org:service:cell:1"
  @config_file "~/.cell/cell.conf"
  @default_context [ cmd: ["list"],
                     st: @default_st ]

  @cmd_aliases %{
    "" => "help",
    "list" => "discover"
  }

  @doc false
  # Setup configuration, parse arguments, invoke command, and print results, theading
  # a context all the way through each fucntion until command is invoked.
  def main(args) do
    @default_context
    |> parse_config_file(@config_file)
    |> parse_args(args)
    |> process_global_options
    |> invoke_command
    |> IO.puts
  end

  # merge config file in with context
  defp parse_config_file(context, config_file) do
    conf_path = Path.expand config_file
    if File.exists?(conf_path) do
      case Conform.Parse.file(conf_path) do
        {:error, _} -> context
        {:ok, conf} ->
          case :proplists.get_value(['cell'], conf) do
            :undefined -> context
            cell_config -> Keyword.merge(context, cell_config)
          end
      end
    else
      context
    end
  end

  # parse options from args
  defp parse_args(context, args) do
    case OptionParser.parse(args, [aliases: aliases]) do
      {opts, [cmd|args], []} -> # cmd given, optionally with args/opts
        Keyword.merge(context, cmd: cmd, args: args, opts: opts)
      {opts, [], []} -> # only options given
        Keyword.merge(context, cmd: "", args: [], opts: opts)
      {_, _, errors} ->
        IO.puts "Invalid options: " <> (
          Enum.map(errors, fn({opt, _}) -> opt end)
          |> Enum.join(" ")
        )
        :erlang.halt(1)
    end
  end

  # invoke appropriate command with the given context
  defp invoke_command(context) do
    cmd =
      context[:cmd]
      |> String.downcase
    cmd_module_name =
      (@cmd_aliases[cmd] || cmd)
      |> String.capitalize
    cmd_module = :"Elixir.Nerves.Cell.CLI.Cmd.#{cmd_module_name}"
    try do
      cmd_module.run(context)
    rescue UndefinedFunctionError ->
      IO.puts "unknown command: \"#{context[:cmd]}\""
      :erlang.halt(1)
    end
  end

  # handle any global options, merging with default config, and possibly
  # invoking special commands (like -h)
  defp process_global_options(context) do
    case context[:opts] do
      [help: true] -> Keyword.merge(context, cmd: "help")
      _ -> context
    end
  end

  #     #Provision
  #     {[], ["provision", cells, app_id], []} -> Cmd.Provision.run(cells, app_id)
  #     {args, ["provision", cells, app_id], []} -> Cmd.Provision.run(cells, app_id, argv_to_dict(args[:options]))

  #     #Push
  #
  #     {[], ["inspect", cells], []} -> Cmd.Inspect.run(cells)
  #     {[], ["inspect", cells, path], []} -> Cmd.Inspect.run(cells, path)
  #     # IP
  #     # {[cells: cells, ip: ip, mask: mask, router: router], ["static"], []} ->
  #     #   Cmd.Ip.run(cells, ip, mask, router)
  #     #Version
  #     {[], ["version"], _} -> IO.write "cell v#{@cell_tool_version}"
  #     {[version: true], _, _} -> IO.write "cell v#{@cell_tool_version}"
  #     #Default
  #     _ ->
  #       IO.write "Invalid usage or malformed command\n\nUsage:\n\n"
  #       Cmd.Help.run
  #   end
  # end
  #

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
