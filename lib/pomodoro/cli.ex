defmodule Pomodoro.CLI do
  # require IEx
  def main(args \\ []) do
    IO.puts "CLI --> STAR"
    # Application.put_env(:tzdata, :data_dir, "./xxx")
    # Application.put_env(:logger)

    # Application.fetch_env(:tzdata, :data_dir)
    # Application.get_env(app, key, default)
    # Do stuff
    # IEx.pry()
    # IO.puts ">>>> eccomi"
    # [:pomodoro, :logger, :timex, :tzdata]
    # [:logger, :crypto, :asn1, :public_key, :ssl, :idna, :mimerl, :certifi, :ssl_verify_fun, :metrics, :hackney, :tzdata]
    [:pomodoro]
    # |> Enum.map(&Application.load/1)
    |> Enum.map(fn app -> {app, Application.ensure_started(app)} end)
    |> Enum.map(&IO.inspect/1)

    # |> Enum.map(&Application.ensure_started/1)



    # Application.load(:pomodoro)
    # Application.start(:logger)
    # Application.start(:timex)
    # Application.start(:pomodoro)

    # Application.ensure_all_started(:pomodoro)
    Pomodoro.Timer.start_link
    IO.puts "In attesa di uscire"
    receive do
      {:exit,contents} -> IO.puts "Exit"
    end
  end
end
