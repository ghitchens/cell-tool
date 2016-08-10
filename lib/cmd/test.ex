defmodule Nerves.CLI.Cell.Cmd.Test do
  @moduledoc "Not yet implemented"

  alias Nerves.CLI.Cell.Finder

  def run(cspec) do
    HTTPotion.start
    Finder.apply cspec, "Testing", &(test(&1))
  end

  defp test(cell) do
    IO.write "Testing cell: #{cell.location}\n"
  end
end
