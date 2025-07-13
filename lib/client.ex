defmodule JazExTreme.Client do
  def client do
    Tesla.client(middleware(), adapter())
  end

  defp adapter do
    :my_app
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:adapter)
  end

  defp middleware do
    [
      Tesla.Middleware.FollowRedirects,
      Tesla.Middleware.FormUrlencoded,
      {Tesla.Middleware.Timeout, timeout: 10_000}
    ]
  end
end
