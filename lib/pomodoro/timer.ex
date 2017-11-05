defmodule Pomodoro.Timer do
  use GenServer
  require Logger

  def start_link(args) do
    Logger.debug "start_link amount: #{inspect args}"
    # GenServer.start_link(__MODULE__, [amount: amount, notify_pid: self()])
    GenServer.start_link(__MODULE__, args)
  end

  def init([amount: amount, notify_pid: notify_pid]) do
    Logger.debug "Start timer and I'm pid: #{inspect self()} with amount: #{inspect amount}"
    {:ok, ref} = :timer.apply_interval(500, __MODULE__, :update, [self()])
    state = %{
      timer_ref: ref,
      interval: Timex.Interval.new(from: Timex.now, until: amount),
      type: :countdown,
      notify_pid: notify_pid,
    }
    {:ok, state}
  end

  def update(pid) do
    GenServer.cast(pid, {:update})
  end

  def handle_cast({:update}, state) do
    if elapsed?(state.interval) do
      stop_timer(state.timer_ref)
      emit_sound()
      notify_elapsed(state)
    else
      update_console(state.interval, state.type)
    end
    {:noreply, state}
  end

  defp update_console(interval, type) do
    IO.write [IO.ANSI.clear_line,"\r",  format_output(interval, type)]
  end

  defp emit_sound(times \\ 3)
  defp emit_sound(0) do end
  defp emit_sound(times) do
    :os.cmd('aplay ~/.pomodoro/end.wav')
    Logger.debug "Emit sound"
    emit_sound(times - 1)
  end

  defp format_output(interval, :countdown) do
    Timex.diff(interval.until, Timex.now, :duration)
      # |> Timex.DateTime.from_timestamp
      |> Timex.format!("%M:%S", :strftime)
  end

  defp format_output(interval, :elapsed) do
    Timex.diff(Timex.now, interval.from, :duration)
    # |> Timex.DateTime.from_timestamp
    |> Timex.format!("%M:%S", :strftime)
  end

  defp elapsed?(interval) do
    Timex.compare(Timex.now, interval.until) >= 0
  end

  # defp close_me do
  #   pid = self()
  #   Logger.debug "Try to stop #{inspect pid}"
  #   spawn(fn ->
  #     r = GenServer.stop(pid)
  #     Application.stop(:pomodoro)
  #   end)
  # end

  defp notify_elapsed(state) do
    Logger.debug("Send message to: #{inspect state.notify_pid}")
    send state.notify_pid, {:timer_elapsed, state.interval}
  end

  defp stop_timer(ref) do
    {:ok, _} = :timer.cancel(ref)
  end

end
