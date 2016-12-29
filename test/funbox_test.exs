defmodule FunBoxTest do
  use ExUnit.Case

  alias FunBox.Redis
  alias FunBox.Primes

  @seconds_to_find_all_primes 60

  test "all prime numbers found" do
    found?(1)
  end

  defp found?(@seconds_to_find_all_primes) do
    Mix.raise "Ooops, not all primes are found " <>
              "in #{@seconds_to_find_all_primes} seconds. " <>
              "Consider decreasing 'n' parameter in config/config.exs " <>
              "or increasing '@seconds_to_find_all_primes' in test/funbox_test.exs"
  end

  defp found?(seconds) do
    if Enum.sort(Redis.set_members) == Enum.sort(Primes.all) do
      assert true
    else
      IO.puts "Waiting: #{seconds}/#{@seconds_to_find_all_primes}"
      Process.sleep(1_000)
      found?(seconds + 1)
    end
  end

end
