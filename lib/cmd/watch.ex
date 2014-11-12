defmodule Cmd.Watch do

	@mcast_log_group {224,0,0,224}
	@mcast_log_port  9999

  def run do
		{:ok, socket} = :gen_udp.open @mcast_log_port, multicast_loop: false, 
        multicast_if: {0, 0, 0, 0}, multicast_ttl: 4
		:ok = :inet.setopts socket, add_membership: {@mcast_log_group, {0,0,0,0}}
		IO.write "watching debug log from multicast group #{Inet.ntoa(@mcast_log_group)}:#{@mcast_log_port}\n\n"
		watch_mcast(socket)
  end

  defp watch_mcast(socket, opts \\ %{}) do 
  	receive do
  		{:udp, socket, {_,_,_,n}, _port, msg} ->
        IO.write ".#{n}\t#{msg}"
  			watch_mcast(socket, opts)
  	end
  end

end
