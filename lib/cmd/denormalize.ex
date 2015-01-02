defmodule Cmd.Denormalize do
  
  require Logger
  
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
  

