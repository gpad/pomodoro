defmodule Pomodoro.Timer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(a) do
    IO.puts "->> INIT #{inspect self}"
    :timer.apply_interval(500, __MODULE__, :update, [self])

    {:ok, {Timex.Interval.new(from: Timex.DateTime.now, until: [minutes: 25]), :countdown}}
  end

  def update(pid) do
    GenServer.cast(pid, {:update})
  end

  def handle_cast({:update}, state) do
    IO.puts format_output(state)
    {:noreply, state}
  end

  defp format_output({interval, :countdown}) do
    Timex.diff(interval.until, Timex.DateTime.now, :timestamp)
      |> Timex.DateTime.from_timestamp
      |> Timex.format!("%M:%S", :strftime)
  end

  defp format_output({interval, :elapsed}) do
    Timex.diff(Timex.DateTime.now, interval.from, :timestamp)
    |> Timex.DateTime.from_timestamp
    |> Timex.format!("%M:%S", :strftime)
  end


end
