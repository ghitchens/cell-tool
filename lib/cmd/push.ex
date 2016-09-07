defmodule Nerves.Cell.CLI.Cmd.Push do
  @moduledoc false

  require Logger

  alias Nerves.Cell.CLI.Finder

  def run(context) do
    context
    |> Finder.discover(single: true)
    |> push_firmware
  end

  defp push_firmware(context) do
    #Logger.info "Got here, context: #{inspect context}"
    [{_id,cell}|_] = context.cells
    [firmware_path|_] = context.args
    firmware_bits = File.read! firmware_path
    HTTPotion.start
    HTTPotion.put(target_uri(cell), body: firmware_bits,
       headers: ["Content-Type": "application/x-firmware"],
       timeout: 12000)
    |> handle_status
  end

  defp target_uri(cell) do
    location = cell[:location]
    case location do
      <<"http:", _rest::binary>> ->
        location
      <<"https:", _rest::binary>> ->
        location
      <<"/_cell/", _rest::binary>> ->
        "http://#{cell.host}:8988/"
      other ->
        IO.puts "Cell gives no valid location for firmware service (got #{other})"
        :erlang.halt(1)
    end
  end

  defp handle_status(%HTTPotion.Response{status_code: 201}) do
    IO.puts "Firmware succesfully updated"
  end
  defp handle_status(%HTTPotion.Response{status_code: x}) do
    IO.puts "Push firmware failed: HTTP #{x}"
    :erlang.halt(1)
  end
  defp handle_status(%HTTPotion.ErrorResponse{message: error_message}) do
    IO.puts "Push firmware failed: #{error_message}"
    :erlang.halt(1)
  end
end
