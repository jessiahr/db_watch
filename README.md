# DbWatch

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `db_watch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:db_watch, "~> 0.1.0"}
  ]
end
```

## Usage
``` elixir
post_watcher = %DbWatch{
      module: PostObserver, 
      db_type: :postgres, 
      conn: PostObserver.db_connection, 
      table: "posts", 
      id: "post_observer"
    }
```