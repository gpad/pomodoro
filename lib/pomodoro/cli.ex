defmodule Pomodoro.CLI do
  require Logger

  def main(args \\ []) do
    Logger.debug "Arguments: #{inspect args}"
    path = Path.expand("~/.pomodoro")
    File.mkdir_p(path)

    Application.put_env(:tzdata, :data_dir, path, persistent: true)

    app_name = Mix.Project.config[:app]
    Application.ensure_all_started(:tzdata)
    Application.ensure_all_started(:timex)
    Application.ensure_all_started(app_name)

    options = parse_args(args)

    do_timer(options)
  end

  defp parse_time(stime) do
    [m, s] = stime |> String.split(":") |> Enum.map(&String.to_integer/1)
    if (Enum.all?([m, s], fn v -> v >= 0 && v < 60 end)) do
      [minutes: m, seconds: s]
    else
      :help
    end
  end

  def parse_args(args) do
    OptionParser.parse(args, switches: [time: :string, help: :boolean], aliases: [t: :time, h: :help])
      |> do_parse()
  end

  defp do_parse({options, [], []}) do
    Enum.reduce(options, [minutes: 25, seconds: 0], fn
      {:help, _}, _acc -> :help
      {:time, v}, _acc -> parse_time(v)
      _, _acc -> :help
    end)
  end
  defp do_parse(_), do: :help

  defp do_timer(:help) do
    IO.puts "-t <amount>, --timer amount\n\tPass the amount of time for timer.\n\tExample: pomodoro -t 5:00"
    System.halt(0)
  end

  defp do_timer(amount) do
    {:ok, _} = Supervisor.start_child(Pomodoro.Supervisor, [[amount: amount, notify_pid: self()]])
    receive do
      {:timer_elapsed, _} ->
        IO.puts "Timer elapsed!"
        System.halt(0)
    end
  end
end
