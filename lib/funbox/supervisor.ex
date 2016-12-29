defmodule FunBox.Supervisor do
  use Supervisor

  alias FunBox.Redis

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      # This guy helps Filter to deal with prime numbers. Application will wait
      # until all prime numbers between 2..n are found and cached in ETS.
      worker(FunBox.Primes, []),

      # https://hexdocs.pm/redix/real-world-usage.html
      # Global Redix
      # For many applications, a single global Redix instance is enough
      # (especially if they're not web applications that hit Redis on every
      # request). A common pattern is to have a named Redix process started
      # under the supervision tree:
      worker(Redix, [Redis.uri(), [name: :redix]]),

      # Leading actors
      worker(FunBox.Generator, []),
      worker(FunBox.Filter, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
