# Pomodoro

Simple CLI application that make a countdown:

## Install
You need to download this repo and build the script with:

```shell
$ mix deps.get
$ MIV_ENV=prod mix escript.build
```

After that you have created the escript and now you should install whit

```shell
mix install
```
It creates a directory `~/.pomodoro` with a `end.wav` that is the sound that will be emitted when times out. It will copy the file in `/usr/local/bin/`. It can be changed passing `--dest_path <my_path>`

## Develop

To develop you can run: `mix escript.build && ./pomodoro`

- The countdown doesn't work
- Create the install task
- Show a progress bar
