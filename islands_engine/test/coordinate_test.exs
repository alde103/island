defmodule CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine

  alias IslandsEngine.Coordinate

  test "new Coordinate" do
    {:ok, _n_coord} = Coordinate.new(1, 1)

    assert n_coord = %Coordinate{col: 1, row: 1}
  end

  test "invalid Coordinates" do
    _response = Coordinate.new(-1, 1)
    assert response = {:error, :invalid_coordinate}

    _response = Coordinate.new(1, 11)
    assert response = {:error, :invalid_coordinate}
  end
end
