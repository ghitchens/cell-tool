defmodule CellTool.Cmd.HelpTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "display help" do
    assert capture_io(fn ->
      Cmd.Help.run()
    end) =~ "cell - discover, update, and debug cellulose cells"
  end
end
