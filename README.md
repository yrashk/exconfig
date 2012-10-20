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

### The "How"

There's just a big of magic happening to make the above thing possible. The `config`
macro wraps every expression in your `do` block with a simple check: if the return value is a MyConfig[] record, fold over it; if not — continue as is. As a result, the accumulated value is the full config.