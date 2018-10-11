defmodule DbWatch.Application do
  use Application

  @offset_manager_module Application.get_env(:db_watch, :offset_manager)
  def start(_type, _args) do
    children = [
      {@offset_manager_module, []}
    ]

    opts = [strategy: :one_for_one, name: DbWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
