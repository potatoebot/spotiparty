defmodule SpotifyAdapter.HTTP do
  @moduledoc """
  Makes the http requests and modifies the session with the results
  """

  alias SpotifyAdapter.Session

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
    {:ok, session}
  end

  @spec refresh_access_token(Session.t()) :: {:ok, Session.t()} | :error
  defp refresh_access_token(_session) do
    :error
  end
end
