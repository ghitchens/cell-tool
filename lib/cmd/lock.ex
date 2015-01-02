defmodule Cmd.Lock do

  @name "lock"

  def run(wspec, cspec) do
		HTTPotion.start
    ware = File.read! wspec
    Finder.apply cspec, "Locking '#{wspec}' to", &(push_to_cell(&1, ware))
  end

  defp push_to_cell(cell, ware) do
		location = cell.location
    {_, _, _, n} = cell.ip
		url = location<>"/sys/firmware/current"
    IO.write "cell: #{n} -> "
		resp = HTTPotion.put(url, ware, ["Content-Type": "application/x-firmware"], timeout: 15000)
		case resp.status_code do
			201 ->  IO.write "ok\n"
			x ->    IO.write "UPDATE FAILED (ERROR #{x})\n"
		end
  end

end



