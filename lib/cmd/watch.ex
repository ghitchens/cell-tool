defmodule Nerves.Cell.CLI.Cmd.Watch do
  @moduledoc """
  Watches the Logging UDP stream of all cells or the specified cell. The output
  is prepended by the last octet of the IP address then the logging message.

  * *UDP address:* 224.0.0.224
  * *Port:* 9999
  """

  @mcast_log_group {224, 0, 0, 224}
  @mcast_log_port 9999

  alias Nerves.Cell.CLI.Inet
  alias Nerves.Cell.CLI.Finder

  def run(context) do
    context
    |> Finder.discover
    |> watch_devices
  end

  defp watch_devices(context) do
    {:ok, socket} = setup_socket
    count = Enum.count(context.cells)
    IO.puts "Found #{count} cells"
    all = (context.args == [])
    if ((not all) and count == 0) do
      IO.puts "(omit filter to watch all LAN activity)"
      :erlang.halt(1)
    end
    context.cells
    |> Enum.map(fn({id, cell}) -> {cell[:ip], id} end)
    |> Enum.into(%{})
    |> watch_ips(socket, all)
  end

  # given a map of ip addresses to cell id's display logs
  defp watch_ips(ips_map, socket, all) do
    receive do
      {:udp, _rcv_socket, source_ip, _port, msg} ->
        case {ips_map[source_ip], all} do
          {nil, true} ->
            IO.write "#{inspect source_ip}\t#{msg}"
          {nil, _} ->
            nil
          {id, _} ->
            IO.write "#{id}\t#{msg}"
        end
        watch_ips(ips_map, socket, all)
    end
  end

  defp setup_socket do
    {:ok, socket} = :gen_udp.open @mcast_log_port, multicast_loop: false,
       multicast_if: {0, 0, 0, 0}, multicast_ttl: 4
    :ok = :inet.setopts socket, add_membership: {@mcast_log_group, {0, 0, 0, 0}}
    IO.puts "Watching log from multicast group #{Inet.ntoa(@mcast_log_group)}:#{@mcast_log_port}\n"
    {:ok, socket}
  end

end
