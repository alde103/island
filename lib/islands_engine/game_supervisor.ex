defmodule IslandsEngine.GameSupervisor do
  use Supervisor
  alias IslandsEngine.Game

  def start_link(_options), do:
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do:
    Supervisor.init([Game], strategy: :simple_one_for_one)

  def start_game(name), do:
    Supervisor.start_child(__MODULE__, [name])

  def stop_game(name) do
    :ets.delete(:game_state, name)
    Supervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end

  def handle_info(:timeout, state_data) do
    {:stop, {:shutdown, :timeout}, state_data}
  end
end
