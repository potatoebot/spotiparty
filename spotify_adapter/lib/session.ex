defmodule SpotifyAdapter.Session do
  @moduledoc """
  Process to hold the state of an authed spotify session and issue api requests

  On init, requres a "code", this comes from the browser request.
  """

  use GenServer

  @token_request_url "https://accounts.spotify.com/api/token"

  @doc """
  Start the session. We require a code from the initial authorization request (from the browser)
  """
  def start_link(initial = %{code: _, http_client: _, client_token: _}) do
    GenServer.start_link(__MODULE__, initial)
  end

  def start_link(initial = %{code: _, client_token: _}) do
    data =
      initial
      |> Map.put(:http_client, HTTPoison)

    GenServer.start_link(__MODULE__, data)
  end

  def request_auth_tokens(session) do
    GenServer.call(session, :request_auth_tokens)
  end

  @impl true
  def handle_call(:request_auth_tokens, _from, state) do
    body = %{
      grant_type: "authorization_code",
      code: state.code,
      redirect_uri: "http://localhost:3000"
    }

    %{
      body: %{
        "access_token" => access_token,
        "scope" => scope,
        "expires_in" => expires_in,
        "refresh_token" => refresh_token
      }
    } = state.http_client.post!(@token_request_url, body, [{:Authorization, state.client_token}])

    new_state =
      state
      |> Map.put(:access_token, access_token)
      |> Map.put(:refresh_token, refresh_token)
      |> Map.put(:scope, scope)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:test, flag, content}, state) do
    send(state.test_reporting_pid, {flag, content})
    {:noreply, state}
  end
end
