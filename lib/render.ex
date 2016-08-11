defmodule Nerves.CLI.Cell.Render do
  @moduledoc """
  Functions to render and format output of CLI commands

  Generally the `cell` CLI discovers and operates on lists of cells,
  which are structured as lists of maps, to preserve order.

  These searches and operations often need to display results
  in tabular format, with optional data in the table.

   This module defines general helpers to format the output of
  such comands.
  """

  alias TableRex.Table

  @default_fields [:cell_id, :result]

  @type column_type :: atom
  @type column_spec :: atom | {atom, column_type}


  @doc """
  Writes tabulated output about cells

  `cells` is a maps of maps (with cell_id as key),

  `column_specs` is a list of column specifications, each of which are
  either a either a simple atom, which defines a key name in the
  data to retrieve, or a {key, Keyword.t} tuple, where map defines
  attributes for that column.

  Returns unmodified cells enumerable (for ease of pipelining)
  """
  @spec table(map, list, String.t | nil) :: String.t
  def table(context, column_specs \\ @default_fields, title \\ nil)
  def table([], _, _), do: []
  def table(%{cells: []}=context, _, _) do
    IO.puts "No matching cells"
    context
  end
  def table(context, column_specs, title) do
    headers =
      column_specs
      |> Nerves.CLI.Cell.Render.HeaderFormatters.headers
    context.cells
    |> Enum.map(&(build_row(&1, column_specs)))
    |> Table.new(headers, title)
    |> Table.render!() #vertical_style: :off, header_separator_symbol: "-")
    |> IO.write
    context
  end

  # #Returns an appropriate table title
  # @spec table_title(map) :: String.t
  # defp table_title(context) do
  #   "\n #{context.cmd}: " <>
  #   case Enum.count(context.cells) do
  #     0 -> "no matching cells"
  #     1 -> "1 cell"
  #     n -> "#{n} cells"
  #   end
  # end

  @spec build_row(map, [column_spec]) :: [String.t]
  defp build_row(cell, column_specs) do
    column_specs
    |> Enum.map(&(build_column(cell, &1)))
  end

  @spec build_column(map, column_spec) :: String.t
  defp build_column({id, _attrs}, :id), do: to_string(id)
  defp build_column({_id, attrs}, a) when is_atom(a), do: to_string(attrs[a])
  defp build_column(cell, {k, type}) when is_atom(k) do
    ColumnFormatters.column(type, cell[k])
  end


  defmodule ColumnFormatters do

    @type column_type :: atom
    @type column_spec :: atom | {atom, column_type}

    @moduledoc false

    alias Nerves.Cell.CLI.Inet
    # fairly simple column formats (defined by an atom type)
    @spec column(column_type, term) :: String.t
    def column(:ip_address, addr), do: Inet.ntoa(addr)
    def column(_, value), do: inspect(value)
  end

  defmodule HeaderFormatters do

    @type column_type :: atom
    @type column_spec :: atom | {atom, column_type}

    @moduledoc false

    # convert a list of atoms
    @spec headers([column_spec]) :: [String.t]
    def headers(column_specs) do
      column_specs
      |> Enum.map(&header_from_spec/1)
    end

    # given a table format the header (for now)
    defp header_from_spec({k,v}) when is_atom(k), do: to_string(k)
    defp header_from_spec(a) when is_atom(a), do: to_string(a)
  end

end
