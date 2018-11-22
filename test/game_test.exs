defmodule GameTest do
  use ExUnit.Case
  doctest IslandsEngine
  alias IslandsEngine.{Game, Board, Island, Guesses, Rules, Coordinate}

  test "Init PID and state" do
    {:ok, game} = Game.start_link("Alde")

    assert is_pid(game)

    state = :sys.get_state(game)

    player1 = %{name: "Alde", board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    d_response = %{player1: player1, player2: player2, rules: %Rules{}}

    assert state == d_response
  end

  test "Add new player" do
    {:ok, game} = Game.start_link("Alde")
    Game.add_player(game, "Dweezil")
    state = :sys.get_state(game)
    assert state.player2.name == "Dweezil"
  end

  test "Position island player" do
    {:ok, game} = Game.start_link("Alde")
    Game.add_player(game, "Dweezil")
    Game.position_island(game, :player1, :square, 1, 1)
    state = :sys.get_state(game)
    {:ok, d_coordinate} = Coordinate.new(1, 1)
    {:ok, sq_i} = Island.new(:square, d_coordinate)
    assert state.player1.board == %{square: sq_i}
    response = Game.position_island(game, :player1, :dot, 12, 1)
    assert response == {:error, :invalid_coordinate}
    response = Game.position_island(game, :player1, :other, 1, 1)
    assert response == {:error, :invalid_island_type}
    response = Game.position_island(game, :player1, :l_shape, 10, 10)
    assert response == {:error, :invalid_coordinate}

    state_data =
      :sys.replace_state(game, fn state_data ->
        %{state_data | rules: %Rules{state: :player1_turn}}
      end)

    assert state_data.rules.state == :player1_turn
    response = Game.position_island(game, :player1, :dot, 4, 1)
    assert response == :error
  end

  test "Set all islands" do
    {:ok, game} = Game.start_link("Alde")
    Game.add_player(game, "Dweezil")
    Game.position_island(game, :player1, :atoll, 1, 1)
    Game.position_island(game, :player1, :dot, 1, 4)
    Game.position_island(game, :player1, :l_shape, 1, 5)
    Game.position_island(game, :player1, :s_shape, 5, 1)
    Game.position_island(game, :player1, :square, 5, 5)
    Game.set_islands(game, :player1)
    state = :sys.get_state(game)
    assert state.rules.player1 == :islands_set
    assert state.rules.state == :players_set
  end

  test "Guess coordinate" do
    {:ok, game} = Game.start_link("Alde")
    assert :error == Game.guess_coordinate(game, :player1, 1, 1)
    Game.add_player(game, "Dweezil")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)
    state_data = :sys.get_state(game)

    :sys.replace_state(game, fn _data ->
      %{state_data | rules: %Rules{state: :player1_turn}}
    end)

    response = Game.guess_coordinate(game, :player1, 5, 5)
    assert response == {:miss, :none, :no_win}
    response = Game.guess_coordinate(game, :player1, 3, 5)
    assert response == :error
    response = Game.guess_coordinate(game, :player2, 1, 1)
    assert response == {:hit, :dot, :win}
  end

  test "register genserver name" do
    via = Game.via_tuple("Lena")
    {:ok, pid} = GenServer.start_link(Game, "Lena", name: via)
    resp = Game.start_link("Lena")
    assert resp == {:error, {:already_started, pid}}
  end
end
