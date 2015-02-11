defmodule Main do

  def main([]), do: main(["help"])
  def main(["help"]), do: Cmd.Help.run

  def main(["normal", cspec]), do: Cmd.Normalize.run(cspec)
  def main(["normalize", cspec]), do: Cmd.Normalize.run(cspec)

  def main(["denormal", cspec]), do: Cmd.Denormalize.run(cspec)
  def main(["denormalize", cspec]), do: Cmd.Denormalize.run(cspec)

  def main(["provision", cspec, app_id]), do: Cmd.Provision.run(cspec, app_id)

  def main(["discover"]), do: main(["discover", nil])
  def main(["discover", cspec]), do: Cmd.Discover.run(cspec)

  def main(["list"]), do: main(["list", nil])
  def main(["list", cspec]), do: Cmd.Discover.run(cspec)

  def main(["push", cspec, wspec]), do: Cmd.Push.run(wspec, cspec)

  def main(["watch"]), do: Cmd.Watch.run
  def main(["watch", cspec]), do: Cmd.Watch.run(cspec)
  
  def main(["reboot", cspec]), do: Cmd.Reboot.run(cspec)
  
  def main(["services", cspec]), do: Cmd.Services.run(cspec)
  def main(["services", cspec, filt]), do: Cmd.Services.run(cspec, filt)

  def main(["test", cspec]), do: Cmd.Test.run(cspec)

  def main(other) do
		cmd = Enum.join(other, " ")
		IO.write "invalid or malformed command: #{cmd}\n"
	end

end
