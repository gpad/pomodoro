defmodule Mix.Tasks.Pomodoro.Install do
  use Mix.Task

  @shortdoc "Install pomodoro timer in /usr/local/bin/"
  @recursive true

  @moduledoc """
  Install the pomodoro script in system.

  The pomodoro script will be installaed in `/usr/local/bin/` unless you
  specify with `-d` argument. It will also install the `end.wav`
  snooze in `~/.pomodoro/`.

  ## Examples

      mix pomodoro.install
      mix pomodoro.install -d <my_path>

  ## Command line options

    * `-d`, `--dest-path` - the repo to create

  """

  @doc false
  def run(args) do
    OptionParser.parse(args, strict: [dest_path: :string], aliases: [d: :dest_path])
      |> parse_args()
      |> check_paths()
      |> do_install()
  end

  defp parse_args({[], [], []}) do
    dest_path = case :os.type() do
      {:unix, :linux} -> "/usr/local/bin/"
      type -> Mix.raise "Operating system not supported #{inspect type}"
    end
    {dest_path, Path.expand("~/.pomodoro")}
  end
  defp parse_args({[dest_path: dest_path], [], []}) do
    {dest_path, Path.expand("~/.pomodoro")}
  end

  defp parse_args({[], [], args}), do: Mix.raise("Unrecognized params: #{inspect args}")
  defp parse_args(args), do: Mix.raise("Unrecognized params: #{inspect args}")

  defp check_paths({dest_path, sound_path}) do
    with :ok <- File.mkdir_p(sound_path),
        {:bin, true} <- {:bin, File.exists?("./pomodoro")},
        true <- File.exists?(dest_path) do
        {dest_path, sound_path}
    else
      {:error, error} -> Mix.raise("Unable to create #{inspect sound_path} '#{inspect error}'")
      false -> Mix.raise("Destination path #{inspect dest_path} doesn't exist")
      {:bin, false} -> Mix.raise("Unable to find executable 'pomodoro' please compile it with\nMIX_ENV=prod mix escript.build")
    end
  end

  defp do_install({dest_path, sound_path}) do
    bin_path = Path.join(dest_path, "pomodoro")
    wav_path = Path.join(sound_path, "end.wav")
    :ok = File.cp("./pomodoro", bin_path)
    :ok = File.cp("./priv/end.wav", wav_path)
    Mix.shell.info("Installation completed!")
    Mix.shell.info("Now you can start pomodoro with #{bin_path}")
    Mix.shell.info("You can customize the soun changing the file #{wav_path}")
  end
end
