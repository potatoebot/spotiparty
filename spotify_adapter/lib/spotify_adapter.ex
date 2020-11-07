defmodule SpotifyAdapter do
  @moduledoc """
  Process to hold the state of an authed spotify session and issue api requests

  On init, requres a "code", this comes from the browser request.
  """

  use GenServer
  alias SpotifyAdapter.Session

  @doc """
  Start the session. We require a code from the initial authorization request (from the browser)
  """
  @spec start_link(Session.t()) :: {:ok, pid()} | {:error, term()}
  def start_link(initial = %Session{code: _}) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, initial)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :auth}}
  end

  @impl true
  def handle_continue(:auth, state) do
    {:noreply, state}
  end
end
