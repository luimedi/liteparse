defmodule LiteParse.Native do
  @moduledoc false
  use Rustler, otp_app: :liteparse, crate: "liteparse_native"

  def parse(_path, _opts), do: :erlang.nif_error(:nif_not_loaded)
  def parse_input(_bytes, _opts), do: :erlang.nif_error(:nif_not_loaded)
end
