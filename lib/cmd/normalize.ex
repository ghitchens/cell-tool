defmodule Cmd.Normalize do
  
  require Logger
  
  def run(cspec) do
		HTTPotion.start
    Finder.apply cspec, "Normalizing", &(normalize(&1))
  end
  
  defp normalize(cell) do
		location = cell.location
    {_, _, _, n} = cell.ip
		url = Path.join location, "/sys/firmware/current"
    IO.write ".#{n} -> "
		resp = HTTPotion.put(url, "{\"status\":\"normal\"}", ["Content-Type": "application/json"])
		case resp.status_code do
			200 ->  IO.write "ok\n"
      400 ->  IO.write "already normal\n"
			x ->    IO.write "NORMALIZATION FAILED (ERROR #{x})\n"
		end
	end

end
  

