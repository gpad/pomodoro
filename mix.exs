defmodule Pomodoro.Mixfile do
  use Mix.Project

  def project do
    [app: :pomodoro,
     version: "0.1.0",
     elixir: "~> 1.5",
     escript: escript(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def escript do
    [main_module: Pomodoro.CLI]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: get_applications(Mix.env),
     mod: {Pomodoro, []}]
  end

  defp get_applications(:test), do: [:logger, :mix, :timex]
  defp get_applications(_), do: [:logger, :mix]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:timex, "~> 3.1"}
    ]
  end
end
