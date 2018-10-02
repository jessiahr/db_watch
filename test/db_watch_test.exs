defmodule DbWatchTest do
  use ExUnit.Case
  doctest DbWatch

  test "greets the world" do
    assert DbWatch.hello() == :world
  end
end
