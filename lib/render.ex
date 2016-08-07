defmodule Nerves.Cell.CLI.Render do
  @moduledoc """
  Functions to render and format output of CLI commands

  Generally the `cell` CLI discovers and operates on lists of cells,
  which are structured as lists of maps, to preserve order.

  These searches and operations often need to display results
  in tabular format, with optional data in the table.

   This module defines general helpers to format the output of
  such comands.
  """

  @default_fields [:cell_id, :result]

  @type column_type :: atom
  @type column_spec :: atom | {atom, column_type}

  @doc """
  Writes a summary of number of matched cells and action being taken.

  Returns unmodified cells enumerable (for ease of pipelining)
  """
  @spec summary(Enumerable.t, String.t) :: String.t
  def summary(cells, verb) do
    case count(cells) do
      0 -> "No matching cells found"
      n -> "#{verb} #{count(cells)} cells"
    end
  end

  @doc """
  Writes tabulated output about cells

  `cells` is a maps of maps (with cell_id as key),

  `column_specs` is a list of column specifications, each of which are
  either a either a simple atom, which defines a key name in the
  data to retrieve, or a {key, Keyword.t} tuple, where map defines
  attributes for that column.

  Returns unmodified cells enumerable (for ease of pipelining)
  """
  @spec table([map], list, String.t | nil) :: String.t
  def table([], _, _), do: []
  def table(cells, column_specs, title \\ nil) do
    cells
    |> Enum.map(&build_row(&1, column_specs))
    |> TableRex.quick_render!(HeaderFormatters.headers(column_specs), title)
  end

  @spec build_row(map, [column_spec]) :: [String.t]
  defp build_row(cell, column_specs) do
    column_specs
    |> Enum.map(&(build_column(cell, &1))
  end

  @spec build_column(map, column_spec) :: String.t
  # shortcut default column format(defined by no column_type)
  defp build_column(cell, a) when is_atom_(a) do
    inspect(cell[a])
  end
  defp build_column(cell, {k, type}) when is_atom_(k) do
    ColumnFormatters.column(type, cell[k])
  end

  defmodule ColumnFormatters do
    @moduledoc false

    alias Nerves.Cell.CLI.Inet
    # fairly simple column formats (defined by an atom type)
    @spec column(column_type, term) :: String.t
    def column(:ip_address, addr), do: Inet.ntoa(ipv4_addr)
  end

  defmodule HeaderFormatters do
    @moduledoc false

    # convert a list of atoms
    @spec headers([column_spec]) :: [String.t]
    def headers(column_specs) do
      column_specs
      |> Enum.map header_from_spec/1
    end

    # given a table format the header (for now)
    defp header_from_spec({k,v}) when is_atom(k), do: to_string(k)
    defp header_from_spec(a) when is_atom(a), do: to_string(a)
  end

end