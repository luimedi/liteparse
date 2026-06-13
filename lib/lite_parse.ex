defmodule LiteParse do
  @moduledoc """
  Elixir wrapper for the [LiteParse](https://github.com/run-llama/liteparse)
  Rust library, providing fast, local PDF and document parsing with spatial
  text extraction.
  """

  alias LiteParse.Config

  @type parse_result :: %{text: String.t(), page_count: non_neg_integer()}

  @doc """
  Parses a document file from disk and returns its extracted text and page count.

  ## Options

  See `LiteParse.Config` for the full list. Pass options as a keyword list:

      LiteParse.parse_file("doc.pdf", max_pages: 100, ocr_enabled: false)

  Or as a reusable struct:

      config = LiteParse.Config.new(ocr_enabled: false)
      LiteParse.parse_file("doc.pdf", config)

  Returns `{:ok, %{text: binary, page_count: integer}}` on success or
  `{:error, reason}` if the file cannot be read or parsed.
  """
  @spec parse_file(Path.t(), keyword() | Config.t()) ::
          {:ok, parse_result()} | {:error, String.t()}
  def parse_file(path, opts \\ []) when is_binary(path) do
    LiteParse.Native.parse_path(path, Config.to_nif(opts))
  end
end
