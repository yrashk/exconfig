defmodule ExConfig do

  defmacro config(module, opts, [do: block]) do
    __config__(module, Keyword.merge(opts, [do: block]), __CALLER__)
  end

  defmacro config(module, opts) do
    __config__(module, opts, __CALLER__)
  end

  defp __config__(module, opts, caller) do
    {string, _} = Code.eval_quoted opts[:string]
    case string do
      string when is_binary(string) ->
        __config__(module, Keyword.merge([do: Code.string_to_ast!(string)], 
                                         Keyword.delete(opts, :string)), caller)
      _ ->
        case opts[:do] do
          {:__block__, _, ops} -> :ok
          nil -> ops = []
          block -> ops = [block]
        end
        quote do
          require Xonad    
          ExConfig.object(Xonad.list do
                            unquote(module)
                            unquote(opts[:as]) = unquote(module).new
                            unquote_splicing(ops)
                          end)
        end
    end
  end

  def object([module, object|rest]), do: object(module, object, rest)
  defp object(_module, object, []), do: object
  defp object(module, object, [update|rest]) do
    diff = (update.to_keywords -- module.new.to_keywords) -- object.to_keywords
    object(module, object.update(diff), rest)
  end
end