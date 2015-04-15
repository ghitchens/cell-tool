defmodule Finder do

  @moduledoc """
  find cells matching cspec
  then put title with number of cells
  then run func with each cell as param
  """

  def apply(cspec, title, func) do
	  if :erlang.is_binary(cspec) and String.length(cspec) > 5 do
			cells = make_static_cell(cspec)
	  else
	    cells = discovered(cspec)
		end
    case Enum.count(cells) do
      0 -> nil
			n ->
        IO.write "#{title} #{n} cell(s)\n"
    		for {_, cell} <- cells do
          func.(cell)
        end
    end
  end

	# return a single cell with the specified location, because the user
	# asked for a specific cell in ip:port form.
	defp make_static_cell(cspec) do
		%{ "remote": %{ location: "http://#{cspec}/nemo", name: cspec }}
	end

  def discovered(spec) do
		cells = SsdpClient.discover |> spec(spec)
    n = Enum.count(cells)
    case spec do
      nil ->
        IO.write "#{n} cells found\n"
      _ ->
        IO.write "#{n} cells found matching \"#{spec}\"\n"
    end
    cells
  end

  # filter the list of supplied cells filtered by the associated spec
  def spec(cells, spec) do
    Enum.filter(cells, &(meets_spec(&1, spec)))
  end

  # decide if a cell meets the spec.  "all" and nil both match all
  # cells.  For now, only the last octet can be used otherwise
  defp meets_spec(cell, spec) do
    {_key, info} = cell
    case spec do
      "all" -> true
      nil -> true
      str -> (str == info.name)
    end
  end

end
