defmodule LiteParse do
  @moduledoc """
  Elixir wrapper for the [LiteParse](https://github.com/run-llama/liteparse)
  Rust library, providing fast, local PDF and document parsing with spatial
  text extraction.
  """

  @doc """
  Parses a document file from disk and returns its full text and page count.

  Only the file path API is exposed right now. `parse_bytes/1` and configuration
  options will land in future versions.

  Returns `{:ok, %{text: binary, page_count: integer}}` on success or
  `{:error, reason}` if the file cannot be read or parsed.

  ## Examples

      iex> LiteParse.parse_file("priv/fixtures/sample.pdf")
      {:ok, %{text: "...", page_count: 3}}

  """
  @spec parse_file(Path.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_file(path) when is_binary(path) do
    LiteParse.Native.parse_path(path)
  end
end
