defmodule Inet do

  def ntoa(ip) do
    ip
    |> :inet_parse.ntoa()
    |> :erlang.list_to_binary()
  end
end
