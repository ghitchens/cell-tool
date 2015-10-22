defmodule Nerves.CLI.Cmd.HelpTest do
  
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Nerves.CLI.Cell.Cmd

  test "display help" do
    assert capture_io(fn ->
      Cmd.Help.run()
    end) =~ "cell - discover, update, and debug cellulose cells"
  end

end
