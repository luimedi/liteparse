defmodule LiteParseTest do
  use ExUnit.Case, async: true

  alias LiteParse.Native

  @demo_pdf Path.join([__DIR__, "demo.pdf"])

  test "returns an error tuple for non-existent files" do
    assert {:error, reason} = Native.parse_path("/no/such/file.pdf")
    assert is_binary(reason)
  end

  test "parse_file/1 delegates to the NIF" do
    assert {:error, _} = LiteParse.parse_file("/no/such/file.pdf")
  end

  describe "parse_file/1 with the demo PDF" do
    @tag :fixture
    test "extracts text and reports page count" do
      assert {:ok, %{text: text, page_count: count}} =
               LiteParse.parse_file(@demo_pdf)

      assert is_binary(text)
      assert text =~ "Lorem ipsum"
      assert is_integer(count)
      assert count >= 1
    end
  end
end
