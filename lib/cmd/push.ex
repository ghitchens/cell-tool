defmodule Cmd.Push do
  @moduledoc """
  Pushes the specified firmware bundle to a cell.
  """

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(wspec, cspec) do
		HTTPotion.start
    ware = File.read! wspec
    Finder.apply cspec, "Pushing ''#{wspec}' to", &(push_to_cell(&1, ware))
  end

  defp push_to_cell(cell, ware) do
		location = cell.location
		url = location<>"/sys/firmware/current"
    IO.write "cell: #{location} -> "
		resp = HTTPotion.put(url, ware, ["Content-Type": "application/x-firmware"], timeout: 120000)
		case resp.status_code do
			201 ->  IO.write "ok\n"
			x ->    IO.write "UPDATE FAILED (ERROR #{x})\n"
		end
  end

end
