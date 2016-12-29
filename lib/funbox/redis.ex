defmodule FunBox.Redis do

  @host Application.get_env(:funbox, :redis_host)
  @port Application.get_env(:funbox, :redis_port)
  @db   Application.get_env(:funbox, :redis_db)

  def uri, do: "redis://#{@host}:#{@port}/#{@db}"

  @queue_key Application.get_env(:funbox, :queue_key)
  @set_key   Application.get_env(:funbox, :result_set_key)

  ## QUEUE API
  ## -----------------------------------------------------------------------------

  def add_to_queue([_n | _ns] = numbers) do
    Redix.command!(:redix, ["RPUSH", @queue_key | numbers])
  end

  def take_1000_numbers_from_queue do
    [numbers, "OK"] = Redix.pipeline!(:redix, [~w(LRANGE #{@queue_key} 0 999),
                                               ~w(LTRIM #{@queue_key} 1000 -1)])
    numbers |> Enum.map(&String.to_integer/1)
  end

  def queue_length do
    Redix.command!(:redix, ~w(LLEN #{@queue_key}))
  end

  def delete_queue do
    Redix.command!(:redix, ~w(DEL #{@queue_key}))
  end

  ## SET API
  ## -----------------------------------------------------------------------------

  def add_to_set([]), do: :ok
  def add_to_set([_n | _ns] = numbers) do
    Redix.command!(:redix, ["SADD", @set_key | numbers])
  end

  def set_members do
    Redix.command!(:redix, ~w(SMEMBERS #{@set_key}))
    |> Enum.map(&String.to_integer/1)
  end

  def set_length do
    Redix.command!(:redix, ~w(SCARD #{@set_key}))
  end

  def delete_set do
    Redix.command!(:redix, ~w(DEL #{@set_key}))
  end  

end
