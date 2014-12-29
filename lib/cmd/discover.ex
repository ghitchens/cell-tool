defmodule Cmd.Discover do
  require Logger
  
  def run(spec, _opts \\ %{}) do
		HTTPotion.start
    Finder.apply spec, "NAME\tIP ADDRESS\tSERIAL#\t\tTYPE\tVERSION -",
      &(IO.write fsr(&1)<>"\n")
  end

  defp fsr(c) do
		location = c.location
    {_, _, _, n} = c.ip
		case Jrtp.get_services(location) do
			{:error, _x} ->
				".#{n}\t#{Inet.ntoa(c.ip)}\tERROR:\t[server: #{c.server} location: #{location}]"
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
            ".#{n}\t#{Inet.ntoa(c.ip)}\t#{sn}\t#{model}\t#{fv}"
          fw_status ->
            ".#{n}\t#{Inet.ntoa(c.ip)}\t#{sn}\t#{model}\t#{fv} (#{fs})"
        end
		end
  end

end
