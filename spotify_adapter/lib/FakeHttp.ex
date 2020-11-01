defmodule SpotifyAdapter.FakeHttp do
  @moduledoc """
  Test double for HttpPoison
  """

  def post(url, body, headers) do
    send(self(), {:test, :http_post, %{url: url, headers: headers, body: body}})
  end
end
