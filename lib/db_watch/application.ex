defmodule DbWatch.Application do
  use Application

  def start(_type, _args) do
    children = [
      {DbWatch.OffsetManager, []}
    ]

    opts = [strategy: :one_for_one, name: DbWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
