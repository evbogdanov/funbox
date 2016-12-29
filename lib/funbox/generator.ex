defmodule FunBox.Generator do
  use GenServer

  alias FunBox.Redis

  @name __MODULE__

  ## API FUNCTIONS
  ## -----------------------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  ## SERVER CALLBACKS
  ## -----------------------------------------------------------------------------

  def init(:ok) do
    # Clean queue every time on startup
    Redis.delete_queue()

    # First 3k random numbers
    generate_3000_random_numbers() |> Redis.add_to_queue()

    # Next 3k coming soon
    schedule_moar_random_numbers()

    # State keeps an eye on the time. I want 3k per second.
    state = %{time: unixtime()}
    {:ok, state}
  end

  def handle_info(:moar_random_numbers, %{time: time} = state) do
    new_state = case unixtime() do
                  ^time ->
                    # Just wait. 3k per this second already generated.
                    state
                  new_time ->
                    # New second. Generate another 3k.
                    generate_3000_random_numbers() |> Redis.add_to_queue()
                    %{time: new_time}
                end
    schedule_moar_random_numbers()
    {:noreply, new_state}
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp unixtime do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp generate_random_number do
    n = Application.get_env(:funbox, :n)
    :rand.uniform(n - 1) + 1
  end

  defp generate_3000_random_numbers do
    Enum.map(1..3000, fn(_) -> generate_random_number() end)
  end

  defp schedule_moar_random_numbers do
    Process.send_after(self(), :moar_random_numbers, 300)
  end

end
