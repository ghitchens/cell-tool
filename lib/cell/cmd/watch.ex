defmodule Nerves.CLI.Cell.Cmd.Watch do
  @moduledoc """
  Watches the Logging UDP stream of all cells or the specified cell. The output
  is prepended by the last octet of the IP address then the logging message.

  UDP address: 224.0.0.224
  Port: 9999
  """

  @mcast_log_group {224, 0, 0, 224}
  @mcast_log_port 9999

  alias Nerves.CLI.Cell.Inet
  
  @doc "Starts the watch on all cells"
  def run do
    {:ok, socket} = setup_socket
    watch_mcast(socket)
  end

  @doc "Starts the watch on the specified cells"
  def run(ip_addr) do
    {:ok, socket} = setup_socket
    watch_mcast(socket, %{ip: ip_addr})
  end

  defp setup_socket do
    {:ok, socket} = :gen_udp.open @mcast_log_port, multicast_loop: false,
       multicast_if: {0, 0, 0, 0}, multicast_ttl: 4
    :ok = :inet.setopts socket, add_membership: {@mcast_log_group, {0, 0, 0, 0}}
    IO.write "watching log from multicast group #{Inet.ntoa(@mcast_log_group)}:#{@mcast_log_port}\n\n"
    {:ok, socket}
  end

  defp watch_mcast(socket, opts \\ %{}) do
    # clean up IP address
    ip = if opts[:ip] do
      [_, ip] = String.split(opts[:ip], ".")
      String.to_integer(ip)
    end
    receive do
      {:udp, _rcv_socket, {_,_,_,n}, _port, msg} ->
        if ip == nil or n == ip do
          IO.write ".#{n}\t#{msg}"
          watch_mcast(socket, opts)
        end
    end
  end
end
