defmodule Pomodoro.CLI do
  require Logger

  def main(args \\ []) do
    Logger.debug "Arguments: #{inspect args}"

    app_name = Mix.Project.config[:app]
    Application.ensure_started(app_name)

    options = parse_args(args)

    do_timer(options)
  end

  # TODO: REFACTORING!!!
  def parse_args(args) do
    {options, [], []} = OptionParser.parse(args, switches: [time: :string, help: :boolean], aliases: [t: :time, h: :help])
    if Keyword.has_key?(options, :time) do
      [m, s] = Keyword.fetch!(options, :time)
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)
      if (Enum.all?([m, s], fn v -> v >= 0 && v < 60 end)) do
        [minutes: m, seconds: s]
      else
        :help
      end
    else
      :help
    end
  end

  defp do_timer(:help) do
    IO.puts "-t <amount>, --timer amount\n\tPass the amount of time for timer.\n\tExample: pomodoro -t 5:00"
    System.halt(0)
  end

  defp do_timer(amount) do
    {:ok, _} = Supervisor.start_child(Pomodoro.Supervisor, [[amount: amount, notify_pid: self]])
    receive do
      {:timer_elapsed, _} ->
        IO.puts "Timer elapsed!"
        System.halt(0)
    end
  end
end
