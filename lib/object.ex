defmodule ExConfig.Object do
  defmacro __using__(_) do
    quote do
      import ExConfig.Object
      @before_compile ExConfig.Object

      use ExConfig.Server

      Module.register_attribute __MODULE__, :property
      Module.register_attribute __MODULE__, :as, persist: false, accumulate: false

      default_as config

    end
  end

  defmacro defproperty({name, _, _}, opts // []) do
    quote line: :keep do
      @property {unquote(name), unquote(opts), [shortdoc: @shortdoc, doc: @doc]}
      Module.delete_attribute __MODULE__, :doc
      Module.delete_attribute __MODULE__, :shortdoc
    end
  end

  defmacro default_as({name, line, _}) do
    quote do
      @as {unquote(name), unquote(line), nil}
    end
  end

  def __accumulate__(property) do
    quote do
      def unquote(property).(value, config) do
        super(unquote(property)(config) ++ [value], config)
      end
    end  
  end

  defmacro __before_compile__(_) do
    quote do
      props = 
      lc {property, opts, _} inlist @property do
        {property, opts[:default]}
      end

      Record.deffunctions props, __ENV__

      lc {property, opts, _} inlist @property do
        if opts[:accumulate] do
          defoverridable [{property, 2}] 
          quoted = ExConfig.Object.__accumulate__(property)
          Module.eval_quoted __MODULE__, quoted
        end
      end

      defmacro config(opts, [do: block]) do
        ExConfig.config(__MODULE__, Keyword.merge([as: @as], Keyword.merge(opts, [do: block])), __CALLER__)
      end

      defmacro config(opts) do
        ExConfig.config(__MODULE__, Keyword.merge([as: @as], opts), __CALLER__)
      end    

      def file!(file) do
        content = File.read!(file)
        content = "require #{inspect __MODULE__}\n" <> content
        {config, _} = Code.eval(content)
        config
      end
    end
  end
end