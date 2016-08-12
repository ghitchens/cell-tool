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
  alias Nerves.Cell.CLI.Cmd
  require Logger

  @cell_tool_version Mix.Project.config[:version]
  @default_st "urn:nerves-project-org:service:cell:1"
  @config_file "~/.cell/cell.conf"

  @service_type_map %{
    "all" => "ssdp:all",
    "nemo" => "urn:rosepointnav-com:service:nemo:1",
    "cell" => "urn:nerves-project-org:service:cell:1"
  }

  @default_context %{
    cmd: "", args: [], opts: [], st: @default_st
  }

  @cmd_aliases %{
    ""=>"help"
  }

  # mapping of commands to modules that handle them
  @cmd_map %{
    "help"    => {Cmd.Help,   nil},
    "list"    => {Cmd.List,   nil},
    "info"    => {Cmd.Info,   nil},
    "push"    => {Cmd.Push,   nil},  #NYI
    "watch"   => {Cmd.Watch,  nil},
    "shell"   => {Cmd.Watch,  nil},
    "reboot"  => {Cmd.Reboot, nil}
  }

  # definition of aliases to be used with OptionParser
  defp aliases, do: [h: :help, v: :version, o: :options, t: :type]

  @doc false
  # Setup configuration, parse arguments, invoke command, and print results, theading
  # a context all the way through each fucntion until command is invoked.
  def main(args) do
    @default_context
    |> parse_config_file(@config_file)
    |> parse_args(args)
    |> process_global_options
    |> invoke_command
  end

  # merge config file in with context
  @spec parse_config_file(map, String.t) :: map
  defp parse_config_file(context, config_file) do
    conf_path = Path.expand config_file
    if File.exists?(conf_path) do
      case Conform.Parse.file(conf_path) do
        {:error, _} -> context
        {:ok, conf} ->
          case :proplists.get_value(['cell'], conf) do
            :undefined -> context
            cell_config -> Map.merge(context, cell_config)
          end
      end
    else
      context
    end
  end

  # parse options from args
  @spec parse_args(map, list) :: map
  defp parse_args(context, args) do
    case OptionParser.parse(args, [aliases: aliases]) do
      {opts, [cmd|args], []} -> # cmd given, optionally with args/opts
        %{context | cmd: cmd, args: args, opts: opts}
      {opts, [], []} -> # only options given
        %{context | cmd: "", args: [], opts: opts}
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
    cmd = context.cmd |> String.downcase
    case @cmd_map[cmd] do
      {cmd_module, cmd_options} ->
        cmd_module.run(context)
      other ->
        IO.puts "unknown command: \"#{cmd}\""
        :erlang.halt(1)
    end
  end

  # handle any global options, merging with default config, and possibly
  # invoking special commands (like -h)
  defp process_global_options(context) do
    Enum.reduce context[:opts], context, &process_option/2
  end

  defp process_option({:"ssdp-type", service_type}, context) do
    case @service_type_map[service_type] do
      nil ->
        IO.puts "unknown service type: #{service_type}"
        :erlang.halt(1)
      st ->
        %{context | st: st}
    end
  end
  defp process_option({:help, true}, context) do
    %{context | cmd: "help"}
  end
  defp process_option({opt, _arg}, context) do
    IO.puts "unknown option: #{opt}"
    :erlang.halt(1)
  end

end
