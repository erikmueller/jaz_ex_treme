defmodule JazExTreme.Client do
  use Tesla

  plug(Tesla.Middleware.FormUrlencoded)
  plug(Tesla.Middleware.Timeout, timeout: 10_000)
end
