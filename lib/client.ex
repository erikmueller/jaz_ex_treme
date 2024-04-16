defmodule JazExTreme.Client do
  use Tesla

  plug(Tesla.Middleware.FormUrlencoded)
end
