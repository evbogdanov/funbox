defmodule FunBox.RedisTest do
  use ExUnit.Case

  alias FunBox.Redis

  setup do
    {:ok, _} = Redix.start_link(Redis.uri(), name: :redix)
    :ok
  end

  test "empty queue" do
    Redis.delete_queue()
    assert Redis.queue_length() == 0
  end

  test "add to queue and delete queue" do
    Redis.add_to_queue([1, 2, 3])
    assert Redis.queue_length() == 3
    Redis.delete_queue()
    assert Redis.queue_length() == 0
  end

  test "take numbers from queue" do
    assert Redis.take_1000_numbers_from_queue() == []
    Redis.add_to_queue([1, 2, 3])
    assert Redis.take_1000_numbers_from_queue() == [1, 2, 3]
    assert Redis.take_1000_numbers_from_queue() == []
    numbers = :lists.seq(1, 3000)
    Redis.add_to_queue(numbers)
    n1 = Redis.take_1000_numbers_from_queue()
    assert hd(n1) == 1
    assert :lists.last(n1) == 1000
    n2 = Redis.take_1000_numbers_from_queue()
    assert hd(n2) == 1001
    assert :lists.last(n2) == 2000
    n3 = Redis.take_1000_numbers_from_queue()
    assert hd(n3) == 2001
    assert :lists.last(n3) == 3000
    assert Redis.take_1000_numbers_from_queue() == []
  end

  test "empty set" do
    Redis.delete_set()
    assert Redis.set_length() == 0
  end

  test "add to set and delete set" do
    assert Redis.add_to_set([]) == :ok
    assert Redis.set_length() == 0
    Redis.add_to_set([1, 2, 2, 3, 3, 3])
    assert Redis.set_length() == 3
    Redis.delete_set()
    assert Redis.set_length() == 0
  end

  test "set members" do
    assert Redis.set_members() == []
    Redis.add_to_set([1])
    assert Redis.set_members() == [1]
  end

end
