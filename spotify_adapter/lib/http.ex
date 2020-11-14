defmodule SpotifyAdapter.HTTP do
  @moduledoc """
  Makes the http requests and modifies the session with the results
  """

  alias SpotifyAdapter.Session

  @access_token_url "https://accounts.spotify.com/api/token"

  @doc """
  Does the given request and creates a new session with the changed values
  """
  @spec do_http(Session.t(), atom()) :: {:ok, Session.t()} | :error
  def do_http(session, op) do
    case op do
      :get_access_token -> get_access_token(session)
      :refresh_access_token -> refresh_access_token(session)
    end
  end

  @spec get_access_token(Session.t()) :: {:ok, Session.t()} | :error
  defp get_access_token(session) do
    http_client().post!(@url, access_token_body(session), access_token_headers(), [])
    {:ok, session}
  end

  @spec refresh_access_token(Session.t()) :: {:ok, Session.t()} | :error
  defp refresh_access_token(_session) do
    :error
  end

  @spec http_client() :: reference()
  defp http_client do
    Application.get_env(:spotify_adapter, :http_client)
  end

  @spec access_token_body(Session.t()) :: String.t()
  def access_token_body(session = %{code: code}) do
    %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_uri()
    }
    |> Jason.encode!()
  end

  defp redirect_uri, do: Application.get_env(:spotify_adapter, :redirect_uri)

  defp access_token_headers do
    [{"Authorization", "Bearer #{auth_token()}"}]
  end

  defp auth_token do
    client_id = Application.get_env(:Spotify_adapter, :client_id)
    client_secret = Application.get_env(:Spotify_adapter, :client_secret)
    Base.encode64("#{client_id}:#{client_secret}")
  end
end
