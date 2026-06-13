defmodule LiteParse.Config do
  @moduledoc """
  Configuration schema for `LiteParse.parse_file/2` and `LiteParse.parse_bytes/2`.

  Mirrors the options exposed by the underlying `liteparse` Rust crate.
  Pass options as a keyword list, e.g.:

      LiteParse.parse_file("doc.pdf", max_pages: 100, ocr_enabled: false)

  Or build a reusable struct:

      config = LiteParse.Config.new(max_pages: 100, ocr_language: "spa")
      LiteParse.parse_file("a.pdf", config)
      LiteParse.parse_bytes(bin, config)
  """

  @default_num_workers max(System.schedulers_online() - 1, 1)

  @schema [
    ocr_language: [
      type: :string,
      default: "eng",
      doc: "OCR language code (Tesseract format: \"eng\", \"fra\", \"deu\", etc.)."
    ],
    ocr_enabled: [
      type: :boolean,
      default: true,
      doc: "Run OCR on text-sparse pages and embedded images."
    ],
    ocr_server_url: [
      type: {:or, [:string, nil]},
      default: nil,
      doc: "HTTP OCR server URL. When nil, uses built-in Tesseract if available."
    ],
    tessdata_path: [
      type: {:or, [:string, nil]},
      default: nil,
      doc: "Path to tessdata directory. Falls back to the TESSDATA_PREFIX env var."
    ],
    max_pages: [
      type: :non_neg_integer,
      default: 1000,
      doc: "Maximum number of pages to parse."
    ],
    target_pages: [
      type: {:or, [:string, nil]},
      default: nil,
      doc: "Range expression like \"1-5,10,15-20\". `nil` means all pages."
    ],
    dpi: [
      type: :float,
      default: 150.0,
      doc: "DPI for rendering pages (used for OCR and screenshots)."
    ],
    output_format: [
      type: {:in, [:json, :text]},
      default: :json,
      doc: "Output format hint passed to the parser."
    ],
    preserve_very_small_text: [
      type: :boolean,
      default: false,
      doc: "Keep very small text that would normally be filtered out."
    ],
    password: [
      type: {:or, [:string, nil]},
      default: nil,
      doc: "Password for encrypted/protected documents."
    ],
    quiet: [
      type: :boolean,
      default: true,
      doc: "Suppress progress output in the Rust layer. Elixir's Logger is unaffected."
    ],
    num_workers: [
      type: :non_neg_integer,
      default: @default_num_workers,
      doc: "Number of concurrent OCR workers."
    ]
  ]

  @type t :: %__MODULE__{
          ocr_language: String.t(),
          ocr_enabled: boolean(),
          ocr_server_url: String.t() | nil,
          tessdata_path: String.t() | nil,
          max_pages: non_neg_integer(),
          target_pages: String.t() | nil,
          dpi: float(),
          output_format: :json | :text,
          preserve_very_small_text: boolean(),
          password: String.t() | nil,
          quiet: boolean(),
          num_workers: non_neg_integer()
        }

  defstruct [
    :ocr_language,
    :ocr_enabled,
    :ocr_server_url,
    :tessdata_path,
    :max_pages,
    :target_pages,
    :dpi,
    :output_format,
    :preserve_very_small_text,
    :password,
    :quiet,
    :num_workers
  ]

  @doc """
  Builds a `%LiteParse.Config{}` from a keyword list, applying defaults
  and validating types.

  Raises `NimbleOptions.ValidationError` on bad input.

  ## Examples

      iex> LiteParse.Config.new(max_pages: 50)
      %LiteParse.Config{max_pages: 50, ocr_language: "eng", ...}
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) when is_list(opts) do
    struct!(__MODULE__, NimbleOptions.validate!(opts, @schema))
  end

  @doc """
  Returns the validated keyword list (with defaults applied) for the given
  options. Accepts a keyword list or a `%LiteParse.Config{}` struct.
  """
  @spec validate(keyword() | t()) :: keyword()
  def validate(opts) do
    NimbleOptions.validate!(opts, @schema)
  end

  @doc """
  Converts the validated options into the map shape expected by the NIF:
  string-keyed map with `output_format` serialised to a lowercase string.

  Accepts a keyword list or a `%LiteParse.Config{}` struct. When given a struct,
  it is trusted as already-validated and just converted; when given a keyword
  list, it goes through `NimbleOptions.validate!/2` first.

  Internal-facing but public to keep `LiteParse.parse_file/2` decoupled from
  the schema definition.
  """
  @spec to_nif(keyword() | t()) :: map()
  def to_nif(%__MODULE__{} = opts) do
    opts
    |> Map.from_struct()
    |> Map.update!(:output_format, &Atom.to_string/1)
  end

  def to_nif(opts) when is_list(opts) do
    opts
    |> validate()
    |> Map.new()
    |> Map.update!(:output_format, &Atom.to_string/1)
  end
end
