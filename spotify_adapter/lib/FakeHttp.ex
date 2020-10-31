defmodule SpotifyAdapter.FakeHttp do
  @moduledoc """
  Test double for HttpPoison
  """

  def get(url, headers) do
    IO.inspect("called")
    IO.inspect(self())
    send(self(), {:test, :http_get, %{url: url, headers: headers}})
  end
end
