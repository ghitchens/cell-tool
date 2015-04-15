defmodule Cmd.Denormalize do
  @moduledoc """

  Denormalizes a cell to enable firmware fallback on a cell. This is
  accomplished by setting the firmware status to `provisional`
  """

  @doc "Takes <cell> paramater from Cmd.main to perform action"
  def run(cspec) do
		HTTPotion.start
    Finder.apply cspec, "Denormalizing", &(normalize(&1))
  end

  defp normalize(cell) do
		location = cell.location
		url = Path.join location, "/sys/firmware/current"
    IO.write "#{cell.name} -> "
		resp = HTTPotion.put(url, "{\"status\":\"provisional\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->  IO.write "ok\n"
      400 ->  IO.write "already provisional\n"
			x ->    IO.write "DENORMALIZATION FAILED (ERROR #{x})\n"
		end
	end

end
