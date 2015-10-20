defmodule Cmd.Provision do

  @moduledoc """
  Provisions  a  box for  use,  assuming  the  device  is running  either  generic
  firmware or firmware with an "open" update policy.

  The app_id is the application ID to install on the box.  A provisioning
  configuration file <app_id>.exs must exist in ~/.cell/provision.
  """

  @name         "lock"
  @lock_mime    "application/x-device-lock"
  @lock_path    "sys/firmware"

  @lock_timeout 15000
  @provision_dir "~/.cell/provision/"

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(cspec, app_id) do
    HTTPotion.start
    Finder.apply cspec, "Provisioning as '#{app_id}'", &(provision(&1, app_id))
  end

  defp provision(cell, app_id) do
    {:ok, services} = Jrtp.get_services(cell)
    {_, config} = Code.eval_file("#{app_id}.exs", @provision_dir)
    serial_number = services.root.serial_number

    # decide if activation/locking is required.  If so, call the custom
    # lock function defined in the configuration, passing the serial#
    case config[:activate] do
      f when is_function(f) ->
        lock_blob = f.(serial_number)
        lock_cell(cell, lock_blob)
      _ -> nil
    end

  end

  defp lock_cell(cell, lock_blob) do
    url = Path.join(cell.location, @lock_path)
    resp = HTTPotion.put(url, lock_blob, ["Content-Type": @lock_mime], timeout: @lock_timeout)
    case resp.status_code do
      201 ->
        IO.write "ok\n"
      204 ->
        IO.write "ok\n"
      x ->
        IO.write "LOCK FAILED (ERROR #{x})\n"
    end
  end
end
