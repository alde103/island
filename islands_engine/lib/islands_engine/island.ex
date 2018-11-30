defmodule IslandsEngine.Island do
  alias __MODULE__
  alias IslandsEngine.Coordinate

  @enforce_keys [:coordinates, :hit_coordinates]

  defstruct [:coordinates, :hit_coordinates]

  # def new(), do: %Island{coordinates: MapSet.new(), hit_coordinates: MapSet.new()}

  @spec new(any(), IslandsEngine.Coordinate.t()) :: any()
  def new(island_type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offset(island_type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @spec overlaps?(
          atom() | %{coordinates: MapSet.t(any())},
          atom() | %{coordinates: MapSet.t(any())}
        ) :: boolean()
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  @spec guess(atom() | %{coordinates: MapSet.t(any())}, any()) ::
          :miss | {:hit, %{coordinates: MapSet.t(any()), hit_coordinates: MapSet.t(any())}}
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @spec forested?(atom() | %{coordinates: MapSet.t(any()), hit_coordinates: MapSet.t(any())}) ::
          boolean()
  def forested?(island), do: MapSet.equal?(island.coordinates, island.hit_coordinates)

  @spec types() :: [:atoll | :dot | :l_shape | :s_shape | :square, ...]
  def types(), do: [:atoll, :dot, :l_shape, :s_shape, :square]

  defp offset(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offset(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offset(:dot), do: [{0, 0}]
  defp offset(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offset(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offset(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end
end
