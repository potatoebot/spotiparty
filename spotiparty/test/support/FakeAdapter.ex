defmodule Spotiparty.FakeAdapter do
  @moduledoc """
  A fake for the spotify adapter
  """

  use GenServer

  @doc """
  Start the session. We require a code from the initial authorization request (from the browser)
  """
  def start_link(initial = %{code: _}) do
    Process.send(Application.get_env(:spotiparty, :test_pid), :adapter_start, [])
    GenServer.start_link(__MODULE__, %{})
  end

  def request_auth_tokens(session) do
    Process.send(Application.get_env(:spotiparty, :test_pid), :adapter_request_tokens, [])
    GenServer.call(session, :request_auth_tokens)
  end

  def pause(session) do
    GenServer.call(session, :pause)
  end

  def play(session) do
    GenServer.call(session, :play)
  end

  defp compute_client_token do
    "client_token"
  end

  @impl true
  def handle_call(:request_auth_tokens, _from, state) do
    new_state =
      state
      |> Map.put(:access_token, "access_token")
      |> Map.put(:refresh_token, "refresh_token")
      |> Map.put(:scope, "scope")

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
end
