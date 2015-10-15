defmodule SsdpClient do
  @moduledoc """
  Simple SSDP client used for discovery of cells
  """
  require Logger
  
  @discover_gather_time   2000    # wait up to 2 seconds for responses

  @default_ssdp_st "urn:nerves-io:service:cell:1"

  @doc "listen for a bit after an msearch and see who we hear from"
  def discover do
    #IO.puts "==> #{IO.ANSI.green}Searching with SSDP Service Type: #{ssdp_st}#{IO.ANSI.reset}"
    {:ok, socket} = :gen_udp.open(1900, [{:reuseaddr,true}])
    :gen_udp.send(socket, {239,255,255,250}, 1900, msearch_msg)
    Process.send_after self, :timeout, @discover_gather_time
    gather_responses(socket)
  end

  # gather SSDP responses from an open socket until timeout occurs, then
  # close the socket and return the gathered responses
  defp gather_responses(socket, gathered \\ %{}) do
    receive do
      {:udp, socket, host, _port, msg} ->
        gather_responses(socket, merge_gathered(gathered, host, :erlang.list_to_binary(msg)))
      :timeout ->
        :gen_udp.close(socket)
        gathered
    end
  end

  defp merge_gathered(gathered, host, packet) do
    resp = decode_ssdp_packet(packet)
		{usn, resp} = Dict.pop resp, :usn
    {_,_,_,l} = host
		resp = Dict.merge resp, %{ip: host, name: ".#{l}"}
    Dict.put gathered, usn, resp
  end

  # returns keys/values given an ssdp packet
  defp decode_ssdp_packet(packet) do
    {[_raw_http_line], raw_params} = String.split(packet, ["\r\n", "\n"]) |> Enum.split(1)
    #http_line = String.downcase(raw_http_line) |> String.strip
    #{[http_verb, {full_uri], _rest} = String.split(http_line) |> Enum.split(2)
    mapped_params = Enum.map raw_params, fn(x) ->
      case String.split(x, ":", parts: 2) do
        [k, v] -> {String.to_atom(String.downcase(k)), String.strip(v)}
        _ -> nil
      end
    end
    resp = Enum.reject mapped_params, &(&1 == nil)
    Dict.merge(%{}, resp) # convert to map, REVIEW better way?
  end

  def msearch_msg do
    "M-SEARCH * HTTP/1.1\r\n" <>
    "Host: 239.255.255.250:1900\r\n" <>
    "MAN: \"ssdp:discover\"\r\n" <>
    "ST: #{ssdp_st}\r\nMX: 10\r\n\r\n"
  end

  defp ssdp_st do
    path = Path.expand "~/.cell/cell.conf"
    case Conform.Parse.file(path) do
      {:error, _} -> @default_ssdp_st
      {:ok, conf} ->
        # Logger.info "conf: #{inspect conf}"
        case :proplists.get_value(['cell','ssdp_st'], conf) do
          :undefined -> @default_ssdp_st
          st -> st
        end
    end
  end
end
