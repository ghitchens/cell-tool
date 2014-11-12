defmodule Finder do

  @doc """
  find cells matching cspec
  then put title with number of cells
  then run func with each cell as param
  """
  def apply(cspec, title, func) do
    cells = discovered(cspec)
    case Enum.count(cells) do
      0 -> nil
			n ->
        IO.write "#{title} #{n} cell(s)\n"
    		for {_, cell} <- cells do
          func.(cell)
        end
    end  
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
    {key, info} = cell
    case spec do
      "all" -> true
      nil -> true
      str -> 
        {_, _, _, last_octet} = info.ip
        ".#{last_octet}" == str
      _ -> false
    end
  end

end

