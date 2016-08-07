defmodule Nerves.CLI.Cell.Cmd.Normalize do
  @moduledoc """
  Normalizes the firmware on a cell by setting the firmware status to `normal`.
  This is used to "accept" firmware so that upon reboot the device will boot to
  this version of firmware rather then falling back to previous firmware
  version.
  """

  alias Nerves.CLI.Cell.Finder

  @doc "Takes paramater(s) from `Cmd.main` to perform action"
  def run(cspec) do
    HTTPotion.start
    table cspec, "Normalizing", &(normalize(&1))
  end

  defp normalize(cell) do
    cell.location
    |> Path.join("/sys/firmware/current")
    |> HTTPotion.put(~s({"status": "normal"}), ["Content-Type": "application/json"])
    |> verify_status()
    |> response("#{cell.name} -> ")
    |> IO.write()
  end

  defp verify_status(%HTTPotion.Response{status_code: 200}), do: "ok\n"
  defp verify_status(%HTTPotion.Response{status_code: 400}), do: "already normal\n"
  defp verify_status(%HTTPotion.Response{status_code: x}), do: "NORMALIZATION FAILED (ERROR #{x})\n"

  defp response(message, prefix), do: "#{prefix} -> #{message}"
end
