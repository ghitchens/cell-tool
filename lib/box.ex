defmodule Box do

	require Logger

	@mcast_log_group {224,0,0,224}
	@mcast_log_port  9999

  @name "box"
 
  def main([]) do
    main(["help"])
  end

  def main(["help"]) do
    IO.write "#{@name} help\t\tshows this help message\n"
    IO.write "#{@name} discover\t\tfind boxes on the network\n"
    IO.write "#{@name} watch\t\twatch multicast debug log\n"
  end

  def main(["discover"]) do 
		main(["list"])
	end

  def main(["list"]) do
		HTTPotion.start
		cells = SsdpClient.discover
    case Enum.count(cells) do
			0 -> 
				IO.write "No boxes found\n"
			_ -> 
				IO.write format_summary_title <> "\n"
				for cell <- cells do
					IO.write format_summary_row(cell) <> "\n"
				end
    end
  end

  def main(["watch"]) do
		{:ok, socket} = :gen_udp.open @mcast_log_port, multicast_loop: false, 
        multicast_if: {0, 0, 0, 0}, multicast_ttl: 4
		:ok = :inet.setopts socket, add_membership: {@mcast_log_group, {0,0,0,0}}
		IO.write "watching debug log from multicast group #{ntoa(@mcast_log_group)}:#{@mcast_log_port}\n\n"
		watch_mcast(socket)
  end

  def main(other) do
		cmd = Enum.join(other, " ")
		IO.write "box - bad command: #{cmd}\n"
	end

  defp watch_mcast(socket, opts \\ %{}) do 
		receive do
			{:udp, socket, _host, _port, msg} ->
				IO.write msg
				watch_mcast(socket, opts)
		end
	end

  defp format_summary_title do
    "IP ADDRESS\tSERIAL#\t\tDEVICE\tVERSION"
  end
  
  defp format_summary_row({usn, c}) do
		location = c.location
		case get_services(location) do
			{:ok, svcs} -> 
				srd = svcs.root.description
				"#{ntoa(c.ip)}\t#{srd.serial_number}\t#{svcs.root.device_id}\t#{srd.firmware_version}"
			{:error, x} ->
				"#{ntoa(c.ip)}\t[unknown]\tmalfunctioning [server: #{c.server}]"
		end
  end
  
  defp ntoa(ip), do: :inet_parse.ntoa(ip) |> :erlang.list_to_binary

  defp get_services(uri) do
		full_url = uri <> "services"
    resp = HTTPotion.get full_url
		case resp.status_code do
			200 -> JSX.decode resp.body, [{:labels, :atom}]
			x -> {:error, x}
		end
  end

end
