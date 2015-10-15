defmodule Jrtp do

  require Logger
  
  @moduledoc """
  Simple decoder of services document provided by cell
  """

  @doc "gets cells services document and returns {:ok, services}]"
  def get_services(cell) do
    # Logger.info "#{inspect cell}"
    case cell[:location] do
      nil -> 
        { :error, :no_location }
      location -> 
    		full_url = Path.join(location, "services")
        resp = HTTPotion.get full_url
    		case resp.status_code do
    			200 -> 
            JSX.decode resp.body, [{:labels, :atom}]
    			x ->
            raise "Services request for #{full_url} failed with error #{x}"
    		end
    end
  end
end
