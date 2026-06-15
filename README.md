# LiteParse

Elixir wrapper for [LiteParse](https://github.com/run-llama/liteparse), a fast and lightweight PDF parser written in Rust. Parsing runs locally with no cloud dependencies.

Note: this Elixir binding exposes a subset of the upstream LiteParse features and may not yet cover all of them. Check the [upstream project](https://github.com/run-llama/liteparse) for the complete capability set.

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:liteparse, "~> 0.1.0"}
  ]
end
```

## Usage

Parse a PDF from disk:

```elixir
{:ok, %{text: text, page_count: n}} = LiteParse.parse("document.pdf")
```

Parse a PDF from binary data:

```elixir
{:ok, %{text: text, page_count: n}} = LiteParse.parse_input(pdf_binary)
```

Options can be passed as a keyword list:

```elixir
LiteParse.parse("doc.pdf", max_pages: 100, ocr_enabled: false)
```

Or as a reusable struct:

```elixir
config = LiteParse.Config.new(ocr_language: "spa", max_pages: 50)
LiteParse.parse("doc.pdf", config)
```

See `LiteParse.Config` for the full list of available options.

## Development

This project uses [lefthook](https://github.com/evilmartians/lefthook) for Git hooks. A pre-commit hook is configured in `lefthook.yml` to automatically run `mix format` on staged `.ex` and `.exs` files, so you don't have to remember to format manually — fixes are re-staged automatically.

```sh
lefthook install
```

## Supported Formats

- PDF (`.pdf`)
- Microsoft Office (`.docx`, `.xlsx`, `.pptx`, etc.) — requires LibreOffice
- OpenDocument (`.odt`, `.ods`, `.odp`) — requires LibreOffice
- Images (`.png`, `.jpg`, `.tiff`, etc.) — requires ImageMagick

## License

MIT. See [LICENSE](https://github.com/luimedi/liteparse/blob/main/LICENSE).
