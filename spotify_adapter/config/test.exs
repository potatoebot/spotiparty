import Config

config :spotify_adapter,
  http_client: SpotifyAdapter.FakeHTTP,
  redirect_uri: "redirect_uri",
  token_request_url: "https://example.com",
  client_id: "an_id",
  client_secret: "a_secret",
  api_base_url: "example.com",
  env: :test
