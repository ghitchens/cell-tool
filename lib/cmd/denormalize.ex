defmodule Nerves.CLI.Cell.Cmd.Denormalize do
  @moduledoc """

  Denormalizes a cell to enable firmware fallback on a cell. This is
  accomplished by setting the firmware status to `provisional`
  """

  alias Nerves.CLI.Cell.Finder

  @doc "Takes <cell> paramater from Cmd.main to perform action"
  def run(cspec) do
    HTTPotion.start
    table cspec, "Denormalizing", &(normalize(&1))
  end

  defp normalize(cell) do
    cell.location
    |> Path.join("/sys/firmware/current")
    |> HTTPotion.put(~s({"status": "provisional"}), ["Content-Type": "application/json"])
    |> verify_status()
    |> response("#{cell.name} -> ")
    |> IO.write()
  end

  defp verify_status(%HTTPotion.Response{status_code: 200}), do: "ok\n"
  defp verify_status(%HTTPotion.Response{status_code: 400}), do: "already provisional\n"
  defp verify_status(%HTTPotion.Response{status_code: x}), do: "DENORMALIZATION FAILED (ERROR #{x})\n"

  defp response(message, prefix), do: "#{prefix} #{message}"
end
