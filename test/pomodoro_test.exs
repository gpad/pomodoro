defmodule PomodoroTest do
  use ExUnit.Case
  require Logger
  doctest Pomodoro

  test "send timer_elapsed message when timer is elapsed to passed pid" do
    test_pid = self()
    msg = {:ok, :crypto.strong_rand_bytes(12) |> Base.encode64}
    pid = spawn_link fn ->
      assert_receive({:timer_elapsed, _}, 20_000)
      send test_pid, msg
    end
    Logger.debug("Wait message on pid: #{inspect pid}")

    Pomodoro.Timer.start_link([amount: [minutes: 0, seconds: 3], notify_pid: pid])

    assert_receive(^msg, 20_000)
  end

end
