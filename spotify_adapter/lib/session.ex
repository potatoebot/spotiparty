defmodule SpotifyAdapter.Session do
  @moduledoc """
  Type definition and transformations for the spotify adapter session state
  """

  @enforce_keys [:code, :scope]
  defstruct [
    :access_token,
    :client_token,
    :code,
    :expires_after,
    :refresh_token,
    :scope,
    :test_reporting_pid
  ]

  @typedoc """
  Models the state of the spotify session
  """
  @type t() :: %__MODULE__{
          access_token: String.t(),
          client_token: String.t(),
          code: String.t(),
          expires_after: integer(),
          refresh_token: String.t(),
          scope: String.t(),
          test_reporting_pid: pid()
        }

  @doc """
  init a new session
  """
  @spec init(__MODULE__.t()) :: __MODULE__.t()
  def init(session) do
    session
    |> Map.put(:client_token, compute_client_token())
  end

  @doc """
  Set the refresh token, first access token and expires_after for this session.
  """
  @spec get_access_token(__MODULE__.t()) :: __MODULE__.t()
  def get_access_token(session) do
    session
    |> do_http(:get_access_token)
  end

  @doc """
  Use the refresh token to get a new access token
  """
  @spec refresh_access_token(__MODULE__.t()) :: __MODULE__.t()
  def refresh_access_token(session) do
    session
    |> do_http(:refresh_access_token)
  end

  @spec do_http(__MODULE__.t(), atom()) :: __MODULE__.t()
  defp do_http(session, op) do
    case SpotifyAdapter.HTTP.do_http(session, op) do
      {:ok, session} -> session
      :error -> raise("Couldn't get the token, #{inspect(session)}")
    end
  end

  @spec compute_client_token() :: String.t()
  def compute_client_token do
    Base.encode64(
      "#{Application.get_env(:spotify_adapter, :client_id)}:#{
        Application.get_env(:spotify_adapter, :client_secret)
      }"
    )
  end
end
