defmodule Pomodoro.Timer do
  use GenServer
  require Logger
  use Timex

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([amount: amount, notify_pid: notify_pid]) do
    Logger.debug "Start timer - I'm pid: #{inspect self()} with amount: #{inspect amount} notify #{inspect notify_pid}"
    {:ok, ref} = :timer.apply_interval(500, __MODULE__, :update, [self()])
    from = Timex.now
    to = Timex.shift(from, amount)
    state = %{
      timer_ref: ref,
      interval: {from, to},
      type: :countdown,
      notify_pid: notify_pid,
    }
    update_console(state.interval, state.type)
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

  defp format_output({_from, to}, :countdown) do
    d = Timex.diff(to, Timex.now, :duration)
    m = Duration.to_minutes(d, truncate: true)
    s = Duration.to_seconds(d, truncate: true) |> rem(60)
    :io_lib.format("~2..0B:~2..0B", [m, s]) |> List.to_string
  end

  defp format_output({from, _to}, :elapsed) do
    d = Timex.diff(Timex.now, from, :duration)
    m = Duration.to_minutes(d, truncate: true)
    s = Duration.to_seconds(d, truncate: true) |> rem(60)
    :io_lib.format("~2..0B:~2..0B", [m, s]) |> List.to_string
  end

  defp elapsed?({_from, to}) do
    Timex.compare(Timex.now, to) >= 0
  end

  defp notify_elapsed(state) do
    Logger.debug("Send message to: #{inspect state.notify_pid}")
    send state.notify_pid, {:timer_elapsed, state.interval}
  end

  defp stop_timer(ref) do
    {:ok, _} = :timer.cancel(ref)
  end

end
