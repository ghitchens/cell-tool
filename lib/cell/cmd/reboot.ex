defmodule Nerves.CLI.Cell.Cmd.Reboot do
  @moduledoc "Reboots a cell"

  alias Nerves.CLI.Cell.Finder

  @doc "Takes paramater(s) from `Cmd.main` to perform action"
  def run(cspec) do
    HTTPotion.start
    Finder.apply cspec, "Rebooting ", &(enable_reboot(&1))
  end

  defp enable_reboot(cell) do
    cell
    |> create_url()
    |> HTTPotion.put(~s({"enable_reboot": "true"}), ["Content-Type": "application/json"])
    |> verify_status_enable_reboot(cell)
    |> response("reboot enable: #{cell.location} -> ")
    |> IO.write()
  end

  defp execute_reboot(cell) do
    cell
    |> create_url()
    |> HTTPotion.put(~s({"execute_reboot": "true"}), ["Content-Type": "application/json"])
    |> verify_status_ex_reboot()
    |> response("rebooting:")
    |> IO.write()
  end

  defp create_url(cell) do
    cell.location
    |> Path.join("sys/firmware/reboot")
  end

  defp verify_status_enable_reboot(%HTTPotion.Response{status_code: 200}, cell) do
    :timer.sleep(250)
    execute_reboot(cell)
    "enabled\n"
  end
  defp verify_status_enable_reboot(_, _), do: "ERROR\n"

  defp verify_status_ex_reboot(%HTTPotion.Response{status_code: 200}), do: "ok\n"
  defp verify_status_ex_reboot(_), do: "ERROR\n"

  defp response(message, prefix), do: "#{prefix} #{message}"
end
