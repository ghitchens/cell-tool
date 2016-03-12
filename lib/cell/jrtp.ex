defmodule Nerves.CLI.Cell.JRTP do
  @moduledoc """
  Decoder of device information resource provided by the cell
  """

  require Logger

  @doc "gets a cell services JSON resource at location"
  def get_cell_services_resource(location) do
    location
    |> Path.join("services")
    |> HTTPotion.get()
    |> verify_status()
  end

  defp verify_status(%HTTPotion.Response{status_code: 200, body: body}) do
    JSX.decode(body, [{:labels, :atom}])
  end

  defp verify_status(%HTTPotion.Response{status_code: x}) do
    {:error, {:http, x}}
  end
end
