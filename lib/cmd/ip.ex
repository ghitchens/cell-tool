defmodule Cmd.Ip do
  @moduledoc "Not yet implemented"

  def run(cspec, ip, mask, router) do
    HTTPotion.start
    Finder.apply cspec, "Setting", &(setip(&1, ip, mask, router))
  end

  defp setip(cell, ip, mask, router) do
    cell.location
    |> Path.join("/sys/ip/static")
    |> HTTPotion.put(params(ip, mask, router), ["Content-Type": "application/json"])
    |> verify_status()
    |> response("#{cell.name} -> #{params(ip, mask, router)}")
    |> IO.write()
  end

  defp params(ip, mask, router) do
    ~s({"ip": "#{ip}", "mask": "#{mask}", "router": "#{router}"})
  end

  defp verify_status({:ok, %HTTPotion.Response{status_code: 200}}), do: "ok\n"
  defp verify_status({:ok, %HTTPotion.Response{status_code: 400}}), do: "ERROR\n"
  defp verify_status({:ok, %HTTPotion.Response{status_code: x}}), do: "FAILED (ERROR #{x})\n"

  defp response(message, prefix), do: "#{prefix} #{message}"
end
