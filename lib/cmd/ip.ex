defmodule Cmd.Ip do
  @moduledoc "Not yet implemented"

  def run(cspec, ip, mask, router) do
    HTTPotion.start
    Finder.apply cspec, "Setting", &(setip(&1, ip, mask, router))
  end

  defp setip(cell, ip, mask, router) do
    url = Path.join cell.location, "/sys/ip/static"
    IO.write "#{cell.name} -> #{params(ip, mask, router)}"
    resp = HTTPotion.put(url, params(ip, mask, router), ["Content-Type": "application/json"])
    case resp.status_code do
      200 ->
        IO.write "ok\n"
      400 ->
        IO.write "ERROR\n"
      x ->
        IO.write "FAILED (ERROR #{x})\n"
    end
  end

  defp params(ip, mask, router) do
    ~s({"ip": "#{ip}", "mask": "#{mask}", "router": "#{router}"})
  end
end
