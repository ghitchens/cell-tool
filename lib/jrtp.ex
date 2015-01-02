
defmodule Jrtp do
  
  def get_services(cell) do
    location = cell.location
		full_url = Path.join(location, "services")
    resp = HTTPotion.get full_url
		case resp.status_code do
			200 -> JSX.decode resp.body, [{:labels, :atom}]
			x -> 
        raise "Services request for #{full_url} failed with error #{x}"
		end
  end

end