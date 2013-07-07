defmodule ExConfig.Object do
  defmacro __using__(opts) do
    default_as = opts[:default_as] || :config
    quote do
      import ExConfig.Object
      @before_compile ExConfig.Object
      @shortdoc nil
      @doc nil

      Module.register_attribute __MODULE__, :property, accumulate: true

      @as unquote(default_as)
    end
  end

  defmacro defproperty({name, _, _}, opts // []) do
    quote line: :keep do
      @property {unquote(name), unquote(opts), [shortdoc: @shortdoc, doc: @doc]}
      @shortdoc nil
      @doc nil
    end
  end

  def __accumulate__(property) do
    quote do
      def unquote(property).(value, config) do
        super(unquote(property)(config) ++ [value], config)
      end
    end
  end

  def __call_server__(property) do
    quote do
      def unquote(property).(value, server) do
        set_property(server.pid, unquote(property), value)
      end
      def unquote(property).(server) do
        get_property(server.pid, unquote(property))
      end
    end
  end

  def __config__(name, block, module) do
    quote do
      {:ok, pid} = :gen_server.start(unquote(module), nil, [])
      var!(unquote(name)) = unquote(module).new(pid: pid)
      unquote(block)
      result = unquote(module).get_object(pid)
      unquote(module).stop(pid)
      _ = var!(unquote(name))
      result
    end
  end


  defmacro __before_compile__(_) do
    quote do

      props =
      lc {property, opts, _} inlist @property do
        {property, opts[:default]}
      end

      defmodule Server do
        use GenServer.Behaviour
        import GenX.GenServer

        def init(_) do
          {:ok, unquote(__CALLER__.module).new}
        end

        defcall set_property(name, value), state: state do
          state = apply(unquote(__CALLER__.module), name, [value, state])
          {:reply, state, state}
        end

        defcall get_property(name), state: state do
          value = apply(unquote(__CALLER__.module), name, [state])
          {:reply, value, state}
        end

        defcall get_object, state: state do
          {:reply, state, state}
        end
        defcast stop, state: state do
          {:stop, :shutdown, state}
        end

        Record.deffunctions [pid: nil], __ENV__

        lc {property, _, _} inlist Module.get_attribute(unquote(__CALLER__.module), :property) do
          quoted = ExConfig.Object.__call_server__(property)
          Module.eval_quoted __MODULE__, quoted
        end

      end

      Record.deffunctions props, __ENV__

      lc {property, opts, _} inlist @property do
        if opts[:accumulate] do
          defoverridable [{property, 2}]
          quoted = ExConfig.Object.__accumulate__(property)
          Module.eval_quoted __MODULE__, quoted
        end
      end

      defmacro config([do: block]) do
        ExConfig.config({@as, [], nil}, block, Server)
      end

      defmacro config([as: name], [do: block]) do
        ExConfig.config(name, block, Server)
      end

      defmacro config([as: name, do: block]) do
        ExConfig.config(name, block, Server)
      end


      def file!(file) do
        content = File.read!(file)
        content = "require #{inspect __MODULE__}\n" <> content
        {config, _} = Code.eval_string(content)
        config
      end
    end
  end
end