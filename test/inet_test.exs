defmodule CellTool.InetTest do
  use ExUnit.Case, async: true

  test "parse tuple as string" do
    assert Inet.ntoa({192, 168, 1, 1}) == "192.168.1.1"
  end
end
