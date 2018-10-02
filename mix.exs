defmodule DbWatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :db_watch,
      version: "0.1.0",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DbWatch.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:postgrex, git: "https://github.com/elixir-ecto/postgrex"},
      {:mysql, "~> 1.3.1"},
      {:mysqlex, github: "tjheeta/mysqlex" }
    ]
  end
end
