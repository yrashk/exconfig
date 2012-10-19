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

You can also easily use it in conjunction with configuration files:

```elixir
content = File.read! "config.exs"
MyConfig.config string: content
```