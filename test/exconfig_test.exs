Code.require_file "../test_helper.exs", __FILE__

defmodule MyConfig do
  use ExConfig.Object
  defproperty http_port
  defproperty https_port, default: 8081
  defproperty nodes, default: []
  defproperty name, default: [], accumulate: true
  defproperty some
end

defmodule MyOtherConfig do
  use ExConfig.Object, default_as: :other_config
  defproperty http_port
end

defmodule ExconfigTest do
  use ExUnit.Case
  require MyConfig
  require MyOtherConfig
  
  test "setting a value" do
    config =
    MyConfig.config do
       config.http_port 8080
    end

    assert config.http_port == 8080
  end

  test "getting a value" do
    config =
    MyConfig.config do
       config.http_port 8080
       config.http_port config.http_port + 1
    end

    assert config.http_port == 8081
  end

  test "setting multiple values" do
    config =
    MyConfig.config do
       config.http_port 8080
       config.https_port 8082
    end

    assert config.http_port == 8080
    assert config.https_port == 8082    
  end

  test "setting accumulated values" do
    config =
    MyConfig.config do
       config.name "Alice"
       config.name "Bob"
    end

    assert config.name == ["Alice", "Bob"]
  end

  test "default value" do
    config =
    MyConfig.config do
    end

    assert config.https_port == 8081
  end

  test "using non-default as: " do
    config =
    MyConfig.config as: app do
       app.http_port 8080
    end

    assert config.http_port == 8080
  end  

  test "specifying non-default as: " do
    config =
    MyOtherConfig.config do
       other_config.http_port 8080
    end

    assert config.http_port == 8080
  end  

  test "allowing non-config code" do
    config =
    MyConfig.config do
      port = 8079 + 1
      config.http_port port
      _x = 100 + 100 # this is to ensure that the last value might not be the config
    end  

    assert config.http_port == 8080    
  end

  test "included config" do
    config =
    MyConfig.config do
      config.some (MyOtherConfig.config do
        other_config.http_port 8080
      end)
    end     

    assert config.some.http_port == 8080
  end

  test "reading from file" do
    File.write! "__test_config__.exs", %b|
    MyConfig.config do
      config.http_port 9090
    end
    |
    config = MyConfig.file!("__test_config__.exs")
    assert config.http_port == 9090
    File.rm "__test_config__.exs"
  end

end
