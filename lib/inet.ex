defmodule Inet do

  @doc """
  Parses an IP address (given as tuple) and returns an IPv4 or IPv6 address string.
  """
  def ntoa(ip) do
    ip
    |> :inet.ntoa()
    |> :erlang.list_to_binary()
  end
end
