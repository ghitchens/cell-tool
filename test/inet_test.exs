defmodule Nerves.Cell.InetTest do

  use ExUnit.Case, async: true

 alias Nerves.Cell.CLI.Inet
  test "parse tuple as string" do
    assert Inet.ntoa({192, 168, 1, 1}) == "192.168.1.1"
  end
end
