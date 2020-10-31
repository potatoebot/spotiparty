defmodule SpotifyAdapter.Session do
  @moduledoc """
  Process to hold the state of an authed spotify session and issue api requests

  On init, requres a "code", this comes from the browser request.
  """

  use GenServer

  @doc """
  Start the session. We require a code from the initial authorization request (from the browser)
  """
  def start_link(initial = %{code: _, http_client: _}) do
    GenServer.start_link(__MODULE__, initial)
  end

  def request_auth_tokens(session) do
    GenServer.call(session, :request_auth_tokens)
  end

  @impl true
  def handle_call(:request_auth_tokens, _from, state) do
    state.http_client.get("url", "")
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:test, flag, content}, state) do
    send(state.test_reporting_pid, {flag, content})
    {:noreply, state}
  end
end
