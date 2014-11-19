defmodule Cmd.Discover do

  def run(spec, _opts \\ %{}) do
		HTTPotion.start
    Finder.apply spec, "NAME\tIP ADDRESS\tSERIAL#\t\tTYPE\tVERSION -",
      &(IO.write fsr(&1)<>"\n")
  end

  defp fsr(c) do
		location = c.location
    {_, _, _, n} = c.ip
		case Jrtp.get_services(location) do
			{:ok, svcs} ->
				srd = svcs.root
        fw = svcs.firmware
        case fw.firmware_status do
          "normal" ->
    				".#{n}\t#{Inet.ntoa(c.ip)}\t#{srd.serial_number}\t#{srd.model}\t#{fw.version}"
          fw_status ->
    				".#{n}\t#{Inet.ntoa(c.ip)}\t#{srd.serial_number}\t#{fw.model}\t#{fw.version} (#{fw_status})"
        end
			{:error, _x} ->
				".#{n}\t#{Inet.ntoa(c.ip)}\t[unknown]\tmalfunctioning [server: #{c.server}]"
		end
  end

end
