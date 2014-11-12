
defmodule Inet do
  
  def ntoa(ip), do: :inet_parse.ntoa(ip) |> :erlang.list_to_binary

end
