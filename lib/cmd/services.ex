defmodule Cmd.Services do
  
  # TODO: Would be nice to add multiple filters not just one
  # This probably requires reworking main to parse the options better
  def run(cspec, filt \\ nil) do
    HTTPotion.start
    Finder.apply cspec, "Getting Services ", &(get_services_doc(&1, filt))
  end
  
  defp get_services_doc(cell, filt) do
		location = cell.location
		url = location<>"services"
    if filt, do: url = url <> "/#{filt}"
    IO.write "from #{url} -> "
		resp = HTTPotion.get(url)
		case resp.status_code do
			200 ->  
        IO.write "ok\n"
        IO.write "#{resp.body}\n\n"
			x ->    IO.write "ERROR\n"
		end
  end
end