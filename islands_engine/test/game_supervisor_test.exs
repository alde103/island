defmodule GameSupervisorTest do
  use ExUnit.Case, async: true
  doctest IslandsEngine
  alias IslandsEngine.{Game, GameSupervisor}

  test "spawn/stop supervised processes" do
    {:ok, game} = GameSupervisor.start_game("test01")
    via = Game.via_tuple("test01")

    assert game == GenServer.whereis(via)
    assert Process.alive?(game) == true

    GameSupervisor.stop_game("test01")

    assert Process.alive?(game) == false
    assert GenServer.whereis(via) == nil
  end

  test "supervisor test" do
    {:ok, game} = GameSupervisor.start_game("test02")
    via = Game.via_tuple("test02")
    srv_pid = GenServer.whereis(via)
    Game.add_player(game, "Alonso")

    assert game == srv_pid
    assert Process.alive?(srv_pid) == true

    Process.exit(game,:kaboom)
    Process.sleep(100)

    srv_pid = GenServer.whereis(via)
    assert Process.alive?(game) == false
    assert Process.alive?(srv_pid) == true
  end

  test "ETS test" do
    {:ok, game} = GameSupervisor.start_game("test03")
    [{"test03", value}] = :ets.lookup(:game_state, "test03")
    assert value.player1.name == "test03"
    assert value.player2.name == nil

    Game.add_player(game, "Alde")
    [{"test03", value}] = :ets.lookup(:game_state, "test03")
    assert value.player1.name == "test03"
    assert value.player2.name == "Alde"
  end

  test "Terminate test" do
    {:ok, game} = GameSupervisor.start_game("test04")
    via = Game.via_tuple("test04")

    assert game == GenServer.whereis(via)
    assert Process.alive?(game) == true

    GameSupervisor.stop_game("test04")
    resp = :ets.lookup(:game_state, "test04")

    assert Process.alive?(game) == false
    assert GenServer.whereis(via) == nil
    assert resp == []
  end
end
