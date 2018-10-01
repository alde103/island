defmodule IslandTest do
  use ExUnit.Case
  doctest IslandsEngine

  alias IslandsEngine.{Coordinate, Island}
  setup do
    {:ok, v_coordinate} = Coordinate.new(4, 6)
    {:ok, in_coordinate} = Coordinate.new(10, 10)
    %{valid: v_coordinate, invalid: in_coordinate}
  end

  test "new island (valid coordinate)", state do
    {:ok, island} = Island.new(:l_shape, state.valid)
    l_shape_island = [
      %Coordinate{col: 6, row: 4},
      %Coordinate{col: 6, row: 5},
      %Coordinate{col: 6, row: 6},
      %Coordinate{col: 7, row: 6}
    ]
    desired_island = Enum.reduce(l_shape_island, MapSet.new, fn  x, acc -> MapSet.put(acc, x) end)
    assert island = %Island{coordinates: desired_island, hit_coordinates: MapSet.new()}
  end
end
