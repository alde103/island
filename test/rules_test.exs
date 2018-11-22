defmodule RulesTest do
  use ExUnit.Case, sync: true
  doctest IslandsEngine
  alias IslandsEngine.{Rules}

  setup do
    rules = Rules.new()
    %{rules: rules}
  end

  test "initialized -> players_set", state do
    {:ok, rules} = Rules.check(state.rules, :add_player)
    assert rules.state == :players_set
  end

  test "invalid state or stage", state do
    assert :error == Rules.check(state.rules, :x)
    assert :error == Rules.check(%Rules{state: :players_set}, :players_set)
  end

  test "players_set stage", state do
    d_response =
      {:ok, %Rules{player1: :islands_not_set, player2: :islands_not_set, state: :players_set}}

    rules = %{state.rules | state: :players_set}
    assert d_response == Rules.check(rules, {:position_islands, :player1})
    assert d_response == Rules.check(rules, {:position_islands, :player2})
  end

  test "player1_turn transition", state do
    d_response = %Rules{player1: :islands_set, player2: :islands_not_set, state: :players_set}
    rules = %{state.rules | state: :players_set}
    {:ok, response} = Rules.check(rules, {:set_islands, :player1})
    assert d_response == response
    rules = response
    response = Rules.check(rules, {:position_islands, :player1})
    assert :error == response
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert :player1_turn == rules.state
    response = Rules.check(rules, {:position_islands, :player2})
    assert :error == response
    Rules.check(rules, {:set_islands, :player2})
    assert :error == response
  end

  test "player1/2_turn stage", state do
    rules = %{state.rules | state: :player1_turn}
    assert :error == Rules.check(rules, {:guess_coordinate, :player2})
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert :player2_turn == rules.state
    assert :error == Rules.check(rules, {:guess_coordinate, :player1})
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert :player1_turn == rules.state
  end

  test "game_over stage transition", state do
    rules = %{state.rules | state: :player1_turn}
    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert :player1_turn == rules.state
    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert :game_over == rules.state
  end

  test "game_over stage", state do
    rules = %{state.rules | state: :game_over}

    assert :error == Rules.check(rules, {:set_islands, :player1})
    assert :error == Rules.check(rules, {:set_islands, :player2})
    assert :error == Rules.check(rules, {:win_check, :no_win})
    assert :error == Rules.check(rules, {:win_check, :win})
    assert :error == Rules.check(rules, {:position_islands, :player1})
    assert :error == Rules.check(rules, {:position_islands, :player2})
    assert :error == Rules.check(rules, {:guess_coordinate, :player1})
    assert :error == Rules.check(rules, {:guess_coordinate, :player2})
  end
end
