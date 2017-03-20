defmodule Nerves.Cell.CLI do
  @moduledoc """
  High level module that processes commands

  A command module is responsible for taking a context and acting on it, including
  all interactive input/ouput to stdin, stdout, stderr.
  """

  alias Nerves.Cell.CLI.Cmd

  @cell_tool_version Mix.Project.config[:version]
  @default_st "urn:nerves-project-org:service:cell:1"
  @config_file "~/.cell/cell.conf"

  @service_type_map %{
    "all" => "ssdp:all",
    "nemo" => "urn:rosepointnav-com:service:nemo:1",
    "cell" => "urn:nerves-project-org:service:cell:1"
  }

  @default_context %{
    cmd: "",
    args: [],
    opts: [],
    filters: [],
    st: @default_st
  }

  # mapping of commands to modules that handle them
  @cmd_map %{
    "help"    => {Cmd.Help,   nil},
    "list"    => {Cmd.List,   nil},
    "info"    => {Cmd.Info,   nil},
    "push"    => {Cmd.Push,   nil},  #NYI
    "watch"   => {Cmd.Watch,  nil},  #TODO
    "shell"   => {Cmd.Watch,  nil},  #TODO
    "reboot"  => {Cmd.Reboot, nil}   #TODO
  }

  # definition of aliases to be used with OptionParser
  defp aliases, do: [h: :help, v: :version, o: :options, 'S': :stype,
                     f: :firmware ]

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
    case OptionParser.parse(args, [aliases: aliases()]) do
      {[], [], []} -> # nothing given
        %{context | cmd: "help", args: [], opts: []}
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
      {cmd_module, _cmd_options} ->
        cmd_module.run(context)
      _other ->
        {:error, "unknown command: \"#{cmd}\""}
    end
  end

  # handle any global options, merging with default config, and possibly
  # invoking special commands (like -h)
  defp process_global_options(context) do
    Enum.reduce context[:opts], context, &process_option/2
  end

  defp process_option({:stype, service_type}, context) do
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
  defp process_option({:firmware, firmware}, context) do
    Map.put context, :firmware, firmware
  end
  defp process_option({opt, _arg}, _context) do
    IO.puts "unknown option: #{opt}"
    :erlang.halt(1)
  end
end
