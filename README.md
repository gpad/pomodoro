# Pomodoro

Simple CLI application that make a countdown:

To develop you can run: `mix escript.build && ./pomodoro`

## TODO

- Can launch app from different location, we need to set priv data in something like `\home\<user-name>\.pomodoro\priv`
- Give the ability to change the countdown
- Show a progress bar

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `pomodoro` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:pomodoro, "~> 0.1.0"}]
    end
    ```

  2. Ensure `pomodoro` is started before your application:

    ```elixir
    def application do
      [applications: [:pomodoro]]
    end
    ```
