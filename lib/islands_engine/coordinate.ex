defmodule IslandsEngine.Coordinate do
  alias __MODULE__

  @enforce_keys [:row, :col]
  @board_range 1..10

  defstruct [:row, :col]

  @spec new(any(), any()) :: {:error, :invalid_coordinate} | {:ok, IslandsEngine.Coordinate.term()}
  def new(row, col) when row in @board_range and col in @board_range, do:
    {:ok, %Coordinate{row: row, col: col}}

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
