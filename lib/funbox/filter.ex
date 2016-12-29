defmodule FunBox.Filter do
  use GenServer

  alias FunBox.Redis
  alias FunBox.Primes

  @name __MODULE__

  ## API FUNCTIONS
  ## -----------------------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  ## SERVER CALLBACKS
  ## -----------------------------------------------------------------------------

  def init(:ok) do
    # Clean result set on every startup
    Redis.delete_set()

    # Start filtering every 100 ms
    schedule_filtering()

    # No need for state
    state = :ok
    {:ok, state}
  end

  def handle_info(:do_filtering, state) do
    actually_do_filtering()
    schedule_filtering()
    {:noreply, state}
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp schedule_filtering do
    Process.send_after(self(), :do_filtering, 100)
  end

  defp actually_do_filtering do
    Redis.take_1000_numbers_from_queue()
    |> Enum.filter(&Primes.prime?/1)
    |> Redis.add_to_set()
  end

end
