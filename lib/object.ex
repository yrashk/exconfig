defmodule ExConfig.Object do
  defmacro __using__(_) do
    quote do
      import ExConfig.Object
      @before_compile ExConfig.Object

      Module.register_attribute __MODULE__, :property

      defmacro config(opts, [do: block]) do
        ExConfig.config(__MODULE__, Keyword.merge(opts, [do: block]), __CALLER__)
      end

      defmacro config(opts) do
        ExConfig.config(__MODULE__, opts, __CALLER__)
      end

    end
  end

  defmacro defproperty({name, _, _}, opts // []) do
    quote line: :keep do
      @property {unquote(name), unquote(opts), [shortdoc: @shortdoc, doc: @doc]}
      Module.delete_attribute __MODULE__, :doc
      Module.delete_attribute __MODULE__, :shortdoc
    end
  end

  defmacro __before_compile__(_) do
    quote do
      Record.deffunctions __ENV__, (lc {property, opts, _} inlist @property, do: {property, opts[:default]})
    end
  end
end