defmodule Cmd.Normalize do
  @moduledoc """
  Normalizes the firmware on a cell by setting the firmware status to `normal`.
  This is used to "accept" firmware so that upon reboot the device will boot
  to this version of firmware rather then falling back to previous firmware
  version.
  """

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(cspec) do
		HTTPotion.start
    Finder.apply cspec, "Normalizing", &(normalize(&1))
  end

  defp normalize(cell) do
		location = cell.location
		url = Path.join location, "/sys/firmware/current"
    IO.write "#{cell.name} -> "
		resp = HTTPotion.put(url, "{\"status\":\"normal\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->  IO.write "ok\n"
      400 ->  IO.write "already normal\n"
			x ->    IO.write "NORMALIZATION FAILED (ERROR #{x})\n"
		end
	end

end
