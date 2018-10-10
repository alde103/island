defmodule GuessesTest do
  use ExUnit.Case
  doctest IslandsEngine

  alias IslandsEngine.{Coordinate, Guesses}

  setup do
    guesses = Guesses.new

    {:ok, coord1} = Coordinate.new(1, 1)
    {:ok, coord2} = Coordinate.new(9, 7)

    %{guess: guesses, coordinate1: coord1, coordinate2: coord2}
  end

  test "check blank struct", state do
    assert state.guess == %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  test "update guesses (with no overlap)", state do
    g = state.guess
    guesses = update_in(g.hits, &MapSet.put(&1, state.coordinate1))
    assert_map_s = MapSet.new() |> MapSet.put(state.coordinate1)
    assert guesses == %Guesses{hits: assert_map_s, misses: MapSet.new()}

    guesses = update_in(guesses.hits, &MapSet.put(&1, state.coordinate2))
    assert_map_s = assert_map_s |> MapSet.put(state.coordinate2)
    assert guesses == %Guesses{hits: assert_map_s, misses: MapSet.new()}

    guesses = update_in(guesses.hits, &MapSet.put(&1, state.coordinate2))
    assert guesses == %Guesses{hits: assert_map_s, misses: MapSet.new()}
  end

  test "check valid guess", state do
    guesses = Guesses.add(state.guess, :hit, state.coordinate1)
    desired_guesses = MapSet.new() |> MapSet.put(state.coordinate1)
    assert guesses == %Guesses{hits: desired_guesses, misses: MapSet.new()}
  end

  test "check missed guess", state do
    guesses = Guesses.add(state.guess, :miss, state.coordinate1)
    desired_guesses = MapSet.new() |> MapSet.put(state.coordinate1)
    assert guesses == %Guesses{misses: desired_guesses, hits: MapSet.new()}
  end
end
