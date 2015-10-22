defmodule Nerves.CLI.Cell.Cmd.Discover do
  @moduledoc """
  Discoveres cells on the LOcal network and displays key information such as
  the last octet of their IP, serial number, device type, and firmware version.
  """

  alias Nerves.CLI.Cell.JRTP
  alias Nerves.CLI.Cell.Finder

  @doc "Takes paramater(s) from Cmd.main to perform action"
  def run(spec, _opts \\ %{}) do
    HTTPotion.start
    Finder.apply spec, "NAME\tSERIAL#\t\tTYPE\tVERSION -",
      &(IO.write fsr(&1)<>"\n")
  end

  defp fsr(c) do
    case JRTP.get_services(c) do
      {:error, x} ->
        ".#{c.name}\tError #{x} from #{inspect c}"
      {:ok, svcs} ->
        case svcs.root.description do
          description when is_bitstring(description) -> # v2
            sf = svcs.firmware
            sn = svcs.root.serial_number
            model = svcs.root.model
            case sf[:info] do
              nil ->
                fv = "BROKEN"
                fs = "BROKEN"
              fi ->
                fv = fi.version
                fs = fi.status
            end
          srd -> # v1
            fv = srd.firmware_version
            fs = srd.firmware_status
            sn = srd.serial_number
            model = srd.device_id
        end
        case fs do
          "normal" ->
            "#{c.name}\t#{sn}\t#{model}\t#{fv}"
          _fw_status ->
            "#{c.name}\t#{sn}\t#{model}\t#{fv} (#{fs})"
        end
    end
  end
end
