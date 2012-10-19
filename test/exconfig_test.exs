Code.require_file "../test_helper.exs", __FILE__

defmodule MyConfig do
  use ExConfig.Object
  defproperty http_port
  defproperty https_port, default: 8081
end

defmodule ExconfigTest do
  use ExUnit.Case
  require ExConfig

  test "setting a value" do
    config =
    ExConfig.config MyConfig, as: config do
       config.http_port 8080
    end

    assert config.http_port == 8080
  end

  test "setting multiple values" do
    config =
    ExConfig.config MyConfig, as: config do
       config.http_port 8080
       config.https_port 8082
    end

    assert config.http_port == 8080
    assert config.https_port == 8082    
  end
  
  test "default value" do
    config =
    ExConfig.config MyConfig, as: config do
    end

    assert config.https_port == 8081
  end

  test "setting a config from a string (file contents)" do
    config =
    ExConfig.config MyConfig, as: config, string: %b{
       config.http_port 8080
    }
    assert config.http_port == 8080
  end

  test "setting a config from a multiline string (file contents)" do
    config =
    ExConfig.config MyConfig, as: config, string: %b{
       config.http_port 8080
       config.https_port 8082
    }
    assert config.http_port == 8080
    assert config.https_port == 8082
  end

end
