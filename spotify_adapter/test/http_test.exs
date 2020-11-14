defmodule SpotifyAdapter.HTTPTest do
  @moduledoc false

  use ExUnit.Case

  alias SpotifyAdapter.HTTP
  alias SpotifyAdapter.Session

  @code "COWDE"

  defp redirect_uri, do: Application.get_env(:spotify_adapter, :redirect_uri)

  defp auth_token do
    client_id = Application.get_env(:Spotify_adapter, :client_id)
    client_secret = Application.get_env(:Spotify_adapter, :client_secret)
    Base.encode64("#{client_id}:#{client_secret}")
  end

  setup do
    session = %Session{code: @code, scope: ""}
    {:ok, session: session}
  end

  describe "do_http" do
    test "makes the correct http request for :get_access_token", %{session: session} do
      HTTP.do_http(session, :get_access_token)
      assert_received {:http_post, url, body, headers}
      assert url = "https://accounts.spotify.com/api/token"

      assert %{
               grant_type: "authorization_code",
               code: @code,
               redirect_uri: redirect_uri()
             } == Jason.decode!(body, keys: :atoms)

      refute is_nil(redirect_uri())

      assert [{"Authorization", "Bearer #{auth_token()}"}] == headers
    end
  end
end
