Code.require_file "../test_helper.exs", __FILE__

defmodule SystemConfig do
  use ExConfig.Object
  defproperty http_port
  defproperty https_port, default: 8081
end

defmodule ExConfig.ServerTest do
  use ExUnit.Case
  require SystemConfig
  
  test "updating config notifies subscribers" do
    config =
    SystemConfig.config do
       config.http_port 8080
    end

    {:ok, pid} = SystemConfig.start_link(config)

    me = self
    ref = make_ref
    SystemConfig.subscribe(pid, ref, fn(r, config) -> me <- {r, config} end)

    config =
    SystemConfig.config do
       config.http_port 8081
    end

    config.reload(pid)

    receive do
      {^ref, ^config} -> :ok
    end

    SystemConfig.unsubscribe(pid, ref)

    config.reload(pid)

    receive do
      _ -> 
      assert false
    after 100 ->
      assert true
    end

  end

end