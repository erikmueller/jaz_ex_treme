defmodule JazExTreme.MixProject do
  use Mix.Project

  def project do
    [
      app: :jaz_ex_treme,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.11"},
      {:hackney, "~> 1.20"},
      {:floki, "~> 0.36.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
