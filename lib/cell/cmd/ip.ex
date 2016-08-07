defmodule Nerves.CLI.Cell.Cmd.Ip do
  @moduledoc "Not yet implemented"

  alias Nerves.CLI.Cell.Finder

  def run(cspec, ip, mask, router) do
    HTTPotion.start
    table Finder.discover
    |> Render.declare spec, "Setting"
    |> Enum.map &(&1 |> set_ip(ip, mask, router))
    |> Render.tabulate [:name, :ip, :usn, :result]
  end

  @json_ct_hdr = ["Content-Type": "application/json"]
  # attempt to set IP of a cell, return a modified cell with result column
  defp set_ip(cell, ip, mask, router) do
    Dict.merge cell,
      ( cell.location
        |> Path.join("/sys/ip/static")
        |> HTTPotion.put(http_params(ip, mask, router), @json_ct_hdr)
        |> build_result )
  end

  defp http_params(ip, mask, router) do
    ~s({"ip": "#{ip}", "mask": "#{mask}", "router": "#{router}"})
  end

  # given an http response, build a `result` string to show the user
  defp build_result(resp) do
    %{http_response: resp, result: result(resp)}
  end

  defp result(%HTTPotion.Response{status_code: 200}), do: "ok\n"
  defp result(%HTTPotion.Response{status_code: x}), do: "ERROR #{x}\n"
end
