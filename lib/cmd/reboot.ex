defmodule Cmd.Reboot do
  @moduledoc "Reboots a cell"

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(cspec) do
    HTTPotion.start
    Finder.apply cspec, "Rebooting ", &(enable_reboot(&1))
  end

  defp enable_reboot(cell) do
		location = cell.location
		url = location<>"sys/firmware/reboot"
    IO.write "reboot enable: #{location} -> "
		resp = HTTPotion.put(url, "{\"enable_reboot\": \"true\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->
        IO.write "enabled\n"
        :timer.sleep(250)
        execute_reboot(cell)
			x ->    IO.write "ERROR\n"
		end
  end

  defp execute_reboot(cell) do
		location = cell.location
		url = location<>"sys/firmware/reboot"
    IO.write "rebooting:"
		resp = HTTPotion.put(url, "{\"execute_reboot\": \"true\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->
        IO.write "ok\n"
			x ->    IO.write "ERROR\n"
		end
  end
end
