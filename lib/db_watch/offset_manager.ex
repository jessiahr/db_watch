defmodule DbWatch.OffsetManager do
	use Agent
	import Logger

  def start_link(_) do
    Logger.info "Starting DbWatch.OffsetManager"
    {:ok, conn} = Redix.start_link()
    Agent.start_link(fn -> %{data_store: conn} end, name: __MODULE__)
  end

  def put(value, id) do
    Agent.update(__MODULE__, fn(state=%{data_store: data_store}) ->
      Redix.command!(data_store, ["SET", id, value])
      state
    end)
    value
  end

  def get(id) do
    value = Agent.get(__MODULE__, fn(%{data_store: data_store}) ->
      Redix.command!(data_store, ["GET", id])
      |> IO.inspect
    end)
    case value do
    	nil ->
    		nil
    	date ->
    		date
    end
  end
end

