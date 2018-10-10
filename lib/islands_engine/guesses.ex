defmodule IslandsEngine.Guesses do
  alias __MODULE__
  alias IslandsEngine.Coordinate
  @enforce_keys [:hits, :misses]

  defstruct [:hits, :misses]

  @spec new() :: IslandsEngine.Guesses.term()
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(IslandsEngine.Guesses.term(), :hit | :miss, IslandsEngine.Coordinate.term()) :: map()
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate), do:
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate), do:
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
