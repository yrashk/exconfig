defmodule Exconfig.Mixfile do
  use Mix.Project

  def project do
    [ app: :exconfig,
      version: "0.0.1",
      elixir: ">= 0.12.0",
      deps: deps ]
  end

  def application do
    []
  end

  defp deps do
    [ 
      {:genx, github: "yrashk/genx"},
    ]
  end
end
