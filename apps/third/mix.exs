defmodule Third.MixProject do
  use Mix.Project

  def project do
    [
      app: :third,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Third.Application, []},
      optional_applications: [:server]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oban, "~> 2.18"},
      {:phoenix, "~> 1.7.18"},
      {:dns_cluster, "~> 0.2.0"},
      {:db, in_umbrella: true}
    ]
  end
end
