defmodule DbWatch do
  @moduledoc """
  Documentation for DbWatch.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DbWatch.hello
      :world

  """
  defstruct [:module, :db_type, :conn, :table, :id]
  def watch(params=%DbWatch{}) do
    supervisor = {DbWatch.Supervisor, [
      {DbWatch.Watcher, params}
    ]}

    Supervisor.child_spec(supervisor, id: :"db_watch_#{params.id}")
  end
end
