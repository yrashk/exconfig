defmodule ExConfig.Server do
  defmacro __using__(_) do
    quote location: :keep do
      use GenEvent.Behaviour
      import GenX.GenEvent
      alias :gen_event, as: GenEvent

      defrecord State, config: nil, subscribers: []

      def init(config) do
        {:ok, State.new(state: config)}
      end

      def start_link(config) do
        {:ok, pid} = GenEvent.start_link
        add_handler(pid, config)
        {:ok, pid}
      end

      def start_link(name, config) do
        {:ok, pid} = GenEvent.start_link name
        add_handler(pid, config)
        {:ok, pid}
      end

      defp add_handler(pid, config) do
        GenEvent.add_handler(pid, __MODULE__, [config])
      end

      defevent subscribe(ref, f), sync: true, state: state do
        {:ok, state.prepend_subscribers([{ref, f}])}
      end

      defevent unsubscribe(ref), sync: true, state: state do
        {:ok, state.subscribers(List.keydelete(state.subscribers, ref, 0))}
      end

      defevent reload(config), state: state do
        lc {ref, subscriber} inlist state.subscribers do
          subscriber.(ref, config)
        end
        {:ok, state.config(config)}
      end


    end
  end
end
