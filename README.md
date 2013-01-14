# ExConfig

A simplistic configuration library for Elixir.

It allows you to define configurations as modules:

```elixir
defmodule MyConfig do
  use ExConfig.Object
  defproperty http_port
  defproperty https_port, default: 8081
end
```

And then use them to define actual configurations:

```elixir
MyConfig.config do
   config.http_port 8080
end
```

The value returned by the above code will be a `MyConfig` record with `http_port` and
`https_port` configured.

ExConfig can be used to read config files as well:

```elixir
config = MyConfig.file! "config.exs"
```