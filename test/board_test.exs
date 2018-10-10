defmodule BoardTest do
  use ExUnit.Case, sync: true
  doctest IslandsEngine
  alias IslandsEngine.{Board, Coordinate, Island}

    test "board init" do
      board = Board.new()
      d_board = %{}
      assert board == d_board

      {:ok, sq_c} = Coordinate.new(1, 1)
      {:ok, sq_i} = Island.new(:square, sq_c)

      n_board = Board.position_island(board, :square, sq_i)
      d_board = Map.put(d_board, :square, sq_i)
      assert n_board == d_board

      {:ok, dt_c} = Coordinate.new(2, 2)
      {:ok, dt_i} = Island.new(:dot, dt_c)

      response = Board.position_island(n_board, :dot, dt_i)
      assert response == {:error, :overlapping_island}

      {:ok, dt_c} = Coordinate.new(3, 3)
      {:ok, dt_i} = Island.new(:dot, dt_c)

      n_board = Board.position_island(n_board, :dot, dt_i)
      d_board = Map.put(d_board, :dot, dt_i)
      assert n_board == d_board

      {:ok, m_g} = Coordinate.new(10, 10)

      response = Board.guess(n_board, m_g)
      assert response == {:miss, :none, :no_win, n_board}

      {:ok, h_g} = Coordinate.new(1, 1)

      response = Board.guess(n_board, h_g)
      assert check_hit_guess(response)

      {:ok, w_g} = Coordinate.new(3, 3)
      sq_i_h = %{sq_i | hit_coordinates: sq_i.coordinates}
      n_board = Board.position_island(n_board, :square, sq_i_h)

      response = Board.guess(n_board, w_g)
      assert check_win_guess(response)

    end

    defp check_hit_guess({:hit, :none, :no_win, _}), do: true
    defp check_hit_guess(_x), do: false

    defp check_win_guess({:hit, _, :win, _}), do: true
    defp check_win_guess(_x), do: false
end
