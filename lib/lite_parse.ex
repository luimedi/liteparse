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

      LiteParse.parse("doc.pdf", max_pages: 100, ocr_enabled: false)

  Or as a reusable struct:

      config = LiteParse.Config.new(ocr_enabled: false)
      LiteParse.parse("doc.pdf", config)

  Returns `{:ok, %{text: binary, page_count: integer}}` on success or
  `{:error, reason}` if the file cannot be read or parsed.
  """
  @spec parse(Path.t(), keyword() | Config.t()) ::
          {:ok, parse_result()} | {:error, String.t()}
  def parse(path, opts \\ []) when is_binary(path) do
    LiteParse.Native.parse(path, Config.to_nif(opts))
  end

  @doc """
  Parses a document from in-memory binary data and returns its extracted text
  and page count. Useful when the document is not on disk (e.g. received from
  a network request or an upload).

  Mirrors the underlying `liteparse::LiteParse::parse_input` API with
  `PdfInput::Bytes`.

  ## Options

  See `LiteParse.Config` for the full list. Pass options as a keyword list:

      LiteParse.parse_input(uploaded_pdf_binary, max_pages: 100, ocr_enabled: false)

  Or as a reusable struct:

      config = LiteParse.Config.new(ocr_enabled: false)
      LiteParse.parse_input(uploaded_pdf_binary, config)

  Returns `{:ok, %{text: binary, page_count: integer}}` on success or
  `{:error, reason}` if the data cannot be parsed.
  """
  @spec parse_input(binary(), keyword() | Config.t()) ::
          {:ok, parse_result()} | {:error, String.t()}
  def parse_input(bytes, opts \\ []) when is_binary(bytes) do
    LiteParse.Native.parse_input(bytes, Config.to_nif(opts))
  end
end
