defmodule SpotifyAdapter.FakeHttp do
  @moduledoc """
  Test double for HttpPoison
  """

  def post!(url, body, headers) do
    send(self(), {:test, :http_post, %{url: url, headers: headers, body: body}})

    %{
      body: %{
        "access_token" => "access_token",
        "scope" => "scope",
        "expires_in" => "expires_in",
        "refresh_token" => "refresh_token"
      }
    }
  end
end
