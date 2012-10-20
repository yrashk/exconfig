defmodule ExConfig do

  def config(module, opts, _caller) do
    case opts[:do] do
      {:__block__, _, ops} -> :ok
      nil -> ops = []
      block -> ops = [block]
    end
    as = opts[:as]
    ops = lc op inlist ops do
      quote do 
        case (v = unquote(op)) do
          unquote(module)[] ->
            unquote(as) = v
          _ ->
            unquote(as)
        end
      end
    end
    quote do
      unquote(as) = unquote(module).new
      unquote(as) # suppresses unused variable warning
      unquote_splicing(ops)
    end
  end

  def object([module, object|rest]), do: object(module, object, rest)
  defp object(_module, object, []), do: object
  defp object(module, object, [update|rest]) do
    if is_tuple(update) and elem(update, 0) == module do
      diff = (update.to_keywords -- module.new.to_keywords) -- object.to_keywords
      object(module, object.update(diff), rest)
    else
      object(module, object, rest)
    end
  end
end