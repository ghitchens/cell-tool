
defmodule Jrtp do
  
  def get_services(uri) do
		full_url = Path.join(uri, "services")
    resp = HTTPotion.get full_url
		case resp.status_code do
			200 -> JSX.decode resp.body, [{:labels, :atom}]
			x -> {:error, x}
		end
  end

end