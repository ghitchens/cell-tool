defmodule Cmd.Ip do
  
  require Logger
  
  def run(cspec, ipspec) do
		HTTPotion.start
    Finder.apply cspec, "Setting", &(setip(&1, ipspec))
  end
  
  defp setip(cell, ipspec) do
		url = Path.join cell.location, "/sys/ip/static"
    IO.write "#{cell.name} -> "
		resp = HTTPotion.put(url, "{\"status\":\"normal\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->  IO.write "ok\n"
      400 ->  IO.write "already normal\n"
			x ->    IO.write "NORMALIZATION FAILED (ERROR #{x})\n"
		end
	end

end
  

