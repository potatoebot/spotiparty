defmodule SpotifyAdapter.FakeHTTP do
  @moduledoc false

  def post!(url, body, headers, _options) do
    send(self(), {:http_post, url, body, headers})
  end
end
