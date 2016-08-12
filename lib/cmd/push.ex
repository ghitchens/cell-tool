defmodule Nerves.Cell.CLI.Cmd.Push do
  @moduledoc false

  alias Nerves.Cell.CLI.Render
  alias Nerves.Cell.CLI.Finder

  def run(context) do
    context
    |> Finder.discover(single: true)
    |> push_firmware
  end

  defp push_firmware(context) do
    [cell|_] = context.cells
    [firmware_path|_] = context.args
    host = cell.host
    target_path = cell[:location] || "/"
    firmware_bits = File.read! firmware_path
    HTTPotion.start
    HTTPotion.put target_path, body: firmware_bits, 
                               headers: ["Content-Type": "application/x-firmware"],
                               timeout: 12000
    |> handle_status
  end

  defp handle_status(%HTTPotion.Response{status_code: 201}) do
    IO.puts "Firmware succesfully updated"
  end
  defp return_status(%HTTPotion.Response{status_code: x}) do
    IO.puts "Firmware Update Failed, HTTP #{x}"
    :erlang.halt(1)
  end
end
