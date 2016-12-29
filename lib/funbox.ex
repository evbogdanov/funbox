defmodule FunBox do
  use Application

  def start(_type, _args) do
    FunBox.Supervisor.start_link
  end
end
