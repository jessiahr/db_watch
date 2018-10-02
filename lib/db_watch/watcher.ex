defmodule DbWatch.Watcher do
	use GenServer
  alias DbWatch.DatabaseSource

  @sleep_interval 5
  @db_source_timeout 30_000
  @debug_messages false
  def start_link(params=%DbWatch{}) do
    IO.puts "Starting watcher[#{params.id}]"
    {:ok, db_source} = DatabaseSource.start_link(params)
    GenServer.start_link(__MODULE__, %{params: params, db_source: db_source})

  end

  defp schedule_next_polling(pid) do
    Process.send_after(pid, :start_polling, @sleep_interval * 1000)
  end

  def terminate(failure, state=%{params: params}) do
    IO.puts "Terminating watcher[#{params.id}]"
    if @debug_messages do
      IO.inspect failure
      IO.inspect state
    end
  end

  def tick(pid) do
    # IO.puts "Reading batch"
    case GenServer.call(pid, {:tick}, @db_source_timeout) do
      {[], _} ->
        schedule_next_polling(pid)
        # IO.puts "sleeping"
        :finished_chunk

      {batch, state} ->
        params = state[:params]
        # Emit these!
        apply(params.module, :handle_batch, [batch])

        DatabaseSource.finish_batch(batch)
        Process.send(pid, :start_polling, [])
        # tick(pid)
    end
  end

  def init(state) do
    schedule_next_polling(self)
    {:ok, state}
  end

  def handle_call({:tick}, _from, state=%{db_source: db_source}) do

    batch = DatabaseSource.next_batch(db_source)
    {:reply, {batch, state}, state}
  end

  def handle_info(:start_polling, state) do
      watcher_pid = self
      spawn_link fn ->
        tick(watcher_pid)
      end
      {:noreply, state}
  end
end
