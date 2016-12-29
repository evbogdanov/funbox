defmodule FunBox.Primes do
  use GenServer

  @name __MODULE__

  ## API FUNCTIONS
  ## -----------------------------------------------------------------------------
  
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def prime?(number) do
    GenServer.call(@name, {:is_prime, number})
  end

  def all do
    GenServer.call(@name, :all)
  end

  ## SERVER CALLBACKS
  ## -----------------------------------------------------------------------------

  def init(:ok) do
    # Find all prime numbers between 2..n
    primes = sieve()

    # And cache them in ETS
    :ets.new(:primes, [:set, :named_table])
    Enum.each(primes, fn(prime) -> :ets.insert(:primes, {prime, true}) end)

    # No need for state
    state = :ok
    {:ok, state}
  end

  def handle_call({:is_prime, number}, _from, state) do
    is_prime = case :ets.lookup(:primes, number) do
                 []                -> false
                 [{^number, true}] -> true
               end
    {:reply, is_prime, state}    
  end

  def handle_call(:all, _from, state) do
    all_primes = for {prime, true} <- :ets.tab2list(:primes), do: prime
    {:reply, all_primes, state}
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp sieve do
    n = Application.get_env(:funbox, :n)
    sieve(:lists.seq(2, n))
  end

  defp sieve([]), do: []

  defp sieve([prime | numbers]) do
    numbers2 = for number <- numbers, (rem number, prime) != 0, do: number
    [prime | sieve(numbers2)]
  end

end
