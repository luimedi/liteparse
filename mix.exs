defmodule LiteParse.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/luimedi/liteparse"

  def project do
    [
      app: :liteparse,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_options, "~> 1.1"},
      {:rustler, "~> 0.38.0", runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir wrapper for LiteParse - fast local PDF parsing"
  end

  defp package do
    [
      name: "liteparse",
      description: description(),
      source_url: @source_url,
      licenses: ["MIT"],
      files: ~w(lib native .formatter.exs mix.exs README.md LICENSE* CHANGELOG*),
      links: %{
        GitHub: @source_url
      }
    ]
  end

  defp docs do
    [
      main: "LiteParse",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [{:"README.md", [title: "README"]}]
    ]
  end
end
