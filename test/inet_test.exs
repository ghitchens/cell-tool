defmodule Nerves.ClI.Cell.InetTest do
  
  use ExUnit.Case, async: true

  alias Nerves.CLI.Cell.Inet
  test "parse tuple as string" do
    assert Inet.ntoa({192, 168, 1, 1}) == "192.168.1.1"
  end
end
