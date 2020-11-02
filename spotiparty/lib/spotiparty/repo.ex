defmodule Spotiparty.Repo do
  use Ecto.Repo,
    otp_app: :spotiparty,
    adapter: Ecto.Adapters.Postgres
end
