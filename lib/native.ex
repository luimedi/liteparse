defmodule LiteParse.Native do
  @moduledoc false
  use Rustler, otp_app: :liteparse, crate: "liteparse_native"

  def parse_path(_path, _opts), do: :erlang.nif_error(:nif_not_loaded)
end
