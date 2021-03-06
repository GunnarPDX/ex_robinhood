defmodule ExRobinhood.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_robinhood,
      version: "0.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A Elixir client for the Robinhood API",
      package: package()
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Gunnar Rosenberg"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/GunnarPDX/ex_robinhood"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExRobinhood.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :elixir_uuid, "~> 1.2" },
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
