import Config

config :spotify_adapter,
  token_request_url: "https://accounts.spotify.com/api/token",
  client_id: "c20c55af282e447fa34d7413b6fb8518"

import_config "dev.secret.exs"
