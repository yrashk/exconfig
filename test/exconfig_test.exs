Code.require_file "../test_helper.exs", __FILE__

defmodule MyConfig do
  use ExConfig.Object
  defproperty http_port
  defproperty https_port, default: 8081
  defproperty nodes, default: []
end

defmodule ExconfigTest do
  use ExUnit.Case
  require MyConfig

  test "setting a value" do
    config =
    MyConfig.config as: config do
       config.http_port 8080
    end

    assert config.http_port == 8080
  end

  test "setting multiple values" do
    config =
    MyConfig.config as: config do
       config.http_port 8080
       config.https_port 8082
    end

    assert config.http_port == 8080
    assert config.https_port == 8082    
  end

  test "setting list values" do
    config =
    MyConfig.config as: config do
       config.prepend_nodes ["node1"]
       config.prepend_nodes ["node2"]
    end

    assert config.nodes == ["node2", "node1"]
  end

  test "default value" do
    config =
    MyConfig.config as: config do
    end

    assert config.https_port == 8081
  end

  test "allowing non-config code" do
    config =
    MyConfig.config as: config do
      port = 8079 + 1
      config.http_port port
    end  

    assert config.http_port == 8080    
  end

  test "setting a config from a string (file contents)" do
    config =
    MyConfig.config as: config, string: %b{
       config.http_port 8080
    }
    assert config.http_port == 8080
  end

  test "setting a config from a multiline string (file contents)" do
    config =
    MyConfig.config as: config, string: %b{
       config.http_port 8080
       config.https_port 8082
    }
    assert config.http_port == 8080
    assert config.https_port == 8082
  end

end
