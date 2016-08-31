defmodule CLITest do
  use ExUnit.Case
  import Pomodoro.CLI

  test "parse time arguments" do
    assert parse_args(["--time", "5:00"]) == [minutes: 5, seconds: 0]
  end

  test "parse help arguments" do
    assert parse_args(["--help"]) == :help
  end

  test "ignore wrong parameters" do
    assert parse_args(["--timeX", "5:00"]) == :help
  end

  test "ignore wrong values in time" do
    assert parse_args(["--time", "75:00"]) == :help
    assert parse_args(["--time", "5:60"]) == :help
  end
end
