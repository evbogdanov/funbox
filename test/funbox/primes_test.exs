defmodule FunBox.PrimesTest do
  use ExUnit.Case

  alias FunBox.Primes

  setup do
    {:ok, _} = Primes.start_link
    :ok
  end

  test "all (cached) prime numbers" do
    primes = Enum.sort(Primes.all)
    assert hd(primes) == 2
  end

  test "is prime number" do
    assert Primes.prime?(2) == true
    assert Primes.prime?(3) == true
    assert Primes.prime?(4) == false
  end

end
