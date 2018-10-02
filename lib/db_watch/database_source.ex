defmodule DbWatch.DatabaseSource do
	use GenServer
  alias DbWatch.OffsetManager

	@batch_size 1000
  @db_timeout 30_000

  def start_link(params) do
    offset = OffsetManager.get(params.id)
    GenServer.start_link(__MODULE__, %{db_connection: params.conn, db_type: params.db_type, last_message_at: offset, offset_id: params.id, table: params.table})
  end

  def next_batch(pid) do
    GenServer.call(pid, {:next}, @db_timeout)
  end

  def finish_batch(batch) do

  end

  def handle_call({:next}, _from, state=%{db_connection: conn, last_message_at: last_message_at, db_type: db_type, offset_id: offset_id}) do
    batch = next_query(db_type, state)
    |> format_results(db_type)

    new_offset = last_timestamp_for_batch(state, batch)
    |> OffsetManager.put(offset_id)

  	new_state = Map.put(state, :last_message_at, new_offset)
    {:reply, batch, new_state}
  end

  def next_query(:postgres, %{db_connection: conn, last_message_at: last_message_at, table: table}) when is_nil(last_message_at) do
		Postgrex.query!(conn, "SELECT * FROM #{table} order by updated_at ASC limit $1", [@batch_size])
  end

  def next_query(:postgres, %{db_connection: conn, last_message_at: last_message_at, table: table}) do
  	Postgrex.query!(conn, "SELECT * FROM #{table} WHERE updated_at > $1 order by updated_at ASC limit $2", [last_message_at, @batch_size])
  end

  def next_query(:mysql, %{db_connection: conn, last_message_at: last_message_at, table: table}) when is_nil(last_message_at) do
    {:ok, results} = Mysqlex.Connection.query!(conn, "SELECT * FROM #{table} order by updated_at ASC limit ?", [@batch_size])
    results
  end

  def next_query(:mysql, %{db_connection: conn, last_message_at: last_message_at, table: table}) do
    {:ok, results} = Mysqlex.Connection.query!(conn, "SELECT * FROM #{table} WHERE updated_at > ? order by updated_at ASC limit ?", [last_message_at, @batch_size])
    results
  end

  def format_results(results, :postgres) do
  	columns = results.columns

  	results.rows
  	|> Enum.map(fn(row) ->
  		Enum.zip(columns, row)
  		|> Enum.into(%{})
  	end)
  end

  def format_results(results, :mysql) do
    columns = results.columns

    results.rows
    |> Enum.map(fn(row) ->
      Enum.zip(columns, Tuple.to_list(row))
      |> Enum.into(%{})
    end)
  end

  # this should be updated because there is no way to know that we actually emitted these yet.
  defp last_timestamp_for_batch(%{last_message_at: last_message_at}, []), do: last_message_at
  defp last_timestamp_for_batch(_state, batch) do
		batch
  	|> List.last
  	|> Map.get("updated_at")
    |> NaiveDateTime.from_erl!
    |> NaiveDateTime.to_iso8601
  end


end
