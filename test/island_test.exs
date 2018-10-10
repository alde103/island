defmodule IslandTest do
  use ExUnit.Case, async: false
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
    assert island == %Island{coordinates: desired_island, hit_coordinates: MapSet.new()}
  end

  test "Overlaps" do
    {:ok, sq_c} = Coordinate.new(1, 1)
    {:ok, dt_c} = Coordinate.new(1, 2)
    {:ok, ls_c} = Coordinate.new(5, 5)

    {:ok, sq_i} = Island.new(:square, sq_c)
    {:ok, dt_i} = Island.new(:dot, dt_c)
    {:ok, ls_i} = Island.new(:l_shape, ls_c)

    assert Island.overlaps?(sq_i, dt_i) == true
    assert Island.overlaps?(sq_i, ls_i) == false
    assert Island.overlaps?(ls_i, dt_i) == false
  end

  test "guess a hit and forested?" do
    {:ok, sq_c} = Coordinate.new(1, 1)
    {:ok, dt_c} = Coordinate.new(1, 2)

    {:ok, dt_i} = Island.new(:dot, dt_c)

    assert Island.forested?(dt_i) == false
    assert Island.guess(dt_i, sq_c) == :miss

    {:hit, dt_i} = Island.guess(dt_i, dt_c)
    assert Island.forested?(dt_i) == true
  end
end
