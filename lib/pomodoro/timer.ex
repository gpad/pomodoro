defmodule Pomodoro.Timer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(a) do
    # IO.puts "Start timer and I'm pid: #{inspect self}"
    {:ok, ref} = :timer.apply_interval(500, __MODULE__, :update, [self])
    state = %{
      timer_ref: ref,
      interval: Timex.Interval.new(from: Timex.DateTime.now, until: [minutes: 25]),
      type: :countdown
    }
    {:ok, state}
  end

  def update(pid) do
    GenServer.cast(pid, {:update})
  end

  def handle_cast({:update}, state) do
    if elapsed?(state.interval) do
      stop_timer(state.timer_ref)
      emit_sound
      close_me
    else
      update_console(state.interval, state.type)
    end
    {:noreply, state}
  end

  defp update_console(interval, type) do
    IO.write [IO.ANSI.clear_line,"\r",  format_output(interval, type)]
  end

  defp emit_sound(0) do end

  defp emit_sound(times \\ 3) do
    :os.cmd('aplay priv/end.wav')
    IO.puts "--> Emit sound"
    emit_sound(times - 1)
  end


  defp format_output(interval, :countdown) do
    Timex.diff(interval.until, Timex.DateTime.now, :timestamp)
      |> Timex.DateTime.from_timestamp
      |> Timex.format!("%M:%S", :strftime)
  end

  defp format_output(interval, :elapsed) do
    Timex.diff(Timex.DateTime.now, interval.from, :timestamp)
    |> Timex.DateTime.from_timestamp
    |> Timex.format!("%M:%S", :strftime)
  end

  defp elapsed?(interval) do
    Timex.compare(Timex.DateTime.now, interval.until) >= 0
  end

  defp close_me do
    pid = self
    IO.puts "Try to stop #{inspect pid}"
    spawn(fn ->
      r = GenServer.stop(pid)
      Application.stop(:pomodoro)
    end)
  end

  defp stop_timer(ref) do
    {ok, cancel} = :timer.cancel(ref)
  end

end
