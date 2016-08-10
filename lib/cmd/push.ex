defmodule Nerves.CLI.Cell.Cmd.Push do
  @moduledoc """
  Pushes the specified firmware bundle to a cell.
  """

  alias Nerves.CLI.Cell.Finder

  @doc "Takes paramater(s) from `Cmd.main` to perform action"
  def run(wspec, cspec) do
    HTTPotion.start
    ware = File.read! wspec
    Finder.apply cspec, "Pushing ''#{wspec}' to", &(push_to_cell(&1, ware))
  end

  defp push_to_cell(cell, ware) do
    cell.location
    |> Path.join("/sys/firmware/current")
    |> HTTPotion.put(body: ware, headers: ["Content-Type": "application/x-firmware"], timeout: 120000)
    |> verify_status()
    |> response("cell: #{cell.location} -> ")
    |> IO.write()
  end

  defp verify_status(%HTTPotion.Response{status_code: 201}), do: "ok\n"
  defp verify_status(%HTTPotion.Response{status_code: x}), do: "UPDATE FAILED (ERROR #{x})\n"

  defp response(message, prefix), do: "#{prefix} #{message}"
end
