defmodule ExConfig do

  def config(name, block, module) do
    quote do
      {:ok, var!(pid, unquote(module))} = :gen_server.start(unquote(module), nil, [])
      var!(unquote(name)) = unquote(module).new(pid: var!(pid, unquote(module)))
      unquote(block)
      result = unquote(module).get_object(var!(pid, unquote(module)))
      unquote(module).stop(var!(pid, unquote(module)))
      _ = var!(unquote(name))
      result
    end
  end

end