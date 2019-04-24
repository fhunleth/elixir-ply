defmodule Ply.MixProject do
  use Mix.Project

  def project do
    [
      app: :ply,
      version: "0.1.0",
      elixir: "~> 1.8",
compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      start_permanent: Mix.env() == :prod,
build_embedded: true,
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
      {:elixir_make, "~> 0.5", runtime: false},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false}
    ]
  end
end
