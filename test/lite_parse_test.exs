defmodule LiteParseTest do
  use ExUnit.Case, async: true

  alias LiteParse.{Config, Native}

  @demo_pdf Path.join([__DIR__, "demo.pdf"])

  describe "LiteParse.Config" do
    test "new/1 applies defaults when given an empty keyword list" do
      config = Config.new()

      assert config.ocr_language == "eng"
      assert config.ocr_enabled == true
      assert config.ocr_server_url == nil
      assert config.tessdata_path == nil
      assert config.max_pages == 1000
      assert config.target_pages == nil
      assert config.dpi == 150.0
      assert config.output_format == :json
      assert config.preserve_very_small_text == false
      assert config.password == nil
      assert config.quiet == true
      assert config.num_workers >= 1
    end

    test "new/1 overrides defaults" do
      config = Config.new(max_pages: 50, ocr_enabled: false, dpi: 300.0)

      assert config.max_pages == 50
      assert config.ocr_enabled == false
      assert config.dpi == 300.0
      assert config.output_format == :json
    end

    test "new/1 rejects unknown keys" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Config.new(does_not_exist: 1)
      end
    end

    test "new/1 rejects invalid types" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Config.new(max_pages: -1)
      end

      assert_raise NimbleOptions.ValidationError, fn ->
        Config.new(output_format: :xml)
      end
    end

    test "to_nif/1 returns a string-keyed map ready for the NIF" do
      nif_map = Config.to_nif(output_format: :text, max_pages: 25)

      assert nif_map.output_format == "text"
      assert nif_map.max_pages == 25
      assert nif_map.ocr_language == "eng"
      assert nif_map.quiet == true
      assert is_map(nif_map)
    end

    test "to_nif/1 accepts a Config struct directly" do
      config = Config.new(dpi: 200.0)
      nif_map = Config.to_nif(config)

      assert nif_map.dpi == 200.0
      assert nif_map.output_format == "json"
    end
  end

  describe "parse_file/1,2" do
    test "returns an error tuple for non-existent files" do
      assert {:error, reason} = Native.parse("/no/such/file.pdf", Config.to_nif([]))
      assert is_binary(reason)
    end

    test "parse_file/1 delegates with default options" do
      assert {:error, _} = LiteParse.parse_file("/no/such/file.pdf")
    end

    test "parse_file/2 accepts a keyword list" do
      assert {:error, _} = LiteParse.parse_file("/no/such/file.pdf", max_pages: 5)
    end

    test "parse_file/2 accepts a Config struct" do
      config = Config.new(max_pages: 5)
      assert {:error, _} = LiteParse.parse_file("/no/such/file.pdf", config)
    end

    @tag :fixture
    test "extracts text and reports page count from the demo PDF" do
      assert {:ok, %{text: text, page_count: count}} = LiteParse.parse_file(@demo_pdf)

      assert is_binary(text)
      assert text =~ "Lorem ipsum"
      assert is_integer(count)
      assert count >= 1
    end

    @tag :fixture
    test "honours max_pages override from a keyword list" do
      assert {:ok, %{page_count: count}} =
               LiteParse.parse_file(@demo_pdf, max_pages: 1)

      assert count == 1
    end

    @tag :fixture
    test "honours target_pages override from a keyword list" do
      assert {:ok, %{page_count: count}} =
               LiteParse.parse_file(@demo_pdf, target_pages: "1")

      assert count == 1
    end
  end
end
