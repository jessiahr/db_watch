defmodule DbWatch.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(arg) do
    children = arg
    Supervisor.init(children, strategy: :one_for_one)
  end
end