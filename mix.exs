defmodule Exconfig.Mixfile do
  use Mix.Project

  def project do
    [ app: :exconfig,
      version: "0.0.1",
      deps: deps ]
  end

  def application do
    [applications: :xonad]
  end

  defp deps do
    [ 
     {:xonad, github: "yrashk/xonad"},
    ]
  end
end
