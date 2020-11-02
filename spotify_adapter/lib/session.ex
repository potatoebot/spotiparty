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
  def start_link(initial = %{code: _, http_client: _}) do
    check_env()

    data =
      initial
      |> Map.put(:client_token, compute_client_token())

    GenServer.start_link(__MODULE__, data)
  end

  def start_link(initial = %{code: _}) do
    check_env()

    data =
      initial
      |> Map.put(:http_client, HTTPoison)
      |> Map.put(:client_token, compute_client_token())

    GenServer.start_link(__MODULE__, data)
  end

  def request_auth_tokens(session) do
    GenServer.call(session, :request_auth_tokens)
  end

  def pause(session) do
    GenServer.call(session, :pause)
  end

  def play(session) do
    GenServer.call(session, :play)
  end

  defp check_env do
    if is_nil(Application.get_env(:spotify_adapter, :token_request_url)) do
      raise("token_request_url not set")
    end

    if is_nil(Application.get_env(:spotify_adapter, :client_id)) do
      raise("client_id not set")
    end

    if is_nil(Application.get_env(:spotify_adapter, :client_secret)) do
      raise("client_secret not set")
    end

    if is_nil(Application.get_env(:spotify_adapter, :api_base_url)) do
      raise("api_base_url not set")
    end

    :ok
  end

  defp compute_client_token do
    Base.encode64(
      "#{Application.get_env(:spotify_adapter, :client_id)}:#{
        Application.get_env(:spotify_adapter, :client_secret)
      }"
    )
  end

  @impl true
  def handle_call(:request_auth_tokens, _from, state) do
    body = {
      :form,
      [
        client_id: Application.get_env(:spotify_adapter, :client_id),
        client_secret: Application.get_env(:spotify_adapter, :client_secret),
        grant_type: "authorization_code",
        code: state.code,
        redirect_uri: "https://example.com"
      ]
    }

    %{body: body} = state.http_client.post!(@token_request_url, body, [])

    %{
      "access_token" => access_token,
      "scope" => scope,
      "expires_in" => _expires_in,
      "refresh_token" => refresh_token
    } =
      body
      |> Jason.decode!()

    new_state =
      state
      |> Map.put(:access_token, access_token)
      |> Map.put(:refresh_token, refresh_token)
      |> Map.put(:scope, scope)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:pause, _from, state) do
    state.http_client.put!(
      "#{Application.get_env(:spotify_adapter, :api_base_url)}/v1/me/player/pause",
      [],
      [
        {:Authorization, "Bearer #{state.access_token}"}
      ]
    )

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:play, _from, state) do
    state.http_client.put!(
      "#{Application.get_env(:spotify_adapter, :api_base_url)}/v1/me/player/play",
      [],
      [
        {:Authorization, "Bearer #{state.access_token}"}
      ]
    )

    {:reply, :ok, state}
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_info({:test, flag, content}, state) do
    send(state.test_reporting_pid, {flag, content})
    {:noreply, state}
  end
end
