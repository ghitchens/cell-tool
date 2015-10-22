defmodule Nerves.CLI.Cell.JRTP do
  @moduledoc """
  Simple decoder of services document provided by cell
  """

  require Logger

  @doc "gets cells services document and returns {:ok, services}]"
  def get_services(cell) do
    # Logger.info "#{inspect cell}"
    cell[:location]
    |> cell_location()
  end

  defp cell_location(nil), do: {:error, :no_location}
  defp cell_location(location) do
    location
    |> Path.join("services")
    |> HTTPotion.get()
    |> verify_status()
  end

  defp verify_status(%HTTPotion.Response{status_code: 200, body: body}) do
    JSX.decode(body, [{:labels, :atom}])
  end
  
  defp verify_status(%HTTPotion.Response{status_code: x}) do
    raise "services request failed with HTTP status code #{x}"
  end
end