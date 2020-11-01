defmodule SpotifyAdapter.SessionTest do
  use ExUnit.Case
  alias SpotifyAdapter.FakeHttp
  alias SpotifyAdapter.Session, as: S

  doctest S

  ### TODO:
  # Don't send in the client token.
  # Instead have the start up pull the App vars and compute it
  # Test this, crash if it fails

  setup do
    token_request_url = Application.get_env(:spotify_adapter, :token_request_url)
    client_id = Application.get_env(:spotify_adapter, :client_id)
    client_secret = Application.get_env(:spotify_adapter, :client_secret)

    startup_params = %{
      code: @test_code,
      http_client: FakeHttp,
      test_reporting_pid: self(),
      client_token: @test_client_token
    }

    session = start_supervised!({S, startup_params})
    %{session: session, startup_params: startup_params, token_request_url: token_request_url}
  end

  describe "Startup" do
    test "can start the session server", %{startup_params: startup_params} do
      assert {:ok, _} = S.start_link(startup_params)
    end

    test "must include a code", %{startup_params: startup_params} do
      sp =
        startup_params
        |> Map.delete(:code)

      assert_raise(FunctionClauseError, ~r(no function clause), fn -> S.start_link(sp) end)
    end

    test "defaults to HTTPoison", %{startup_params: startup_params} do
      sp =
        startup_params
        |> Map.delete(:http_client)

      assert {:ok, session} = S.start_link(sp)
      assert %{http_client: HTTPoison} = :sys.get_state(session)
    end

    test "must include a client token", %{startup_params: startup_params} do
      sp =
        startup_params
        |> Map.delete(:client_token)

      assert_raise(FunctionClauseError, ~r(no function clause), fn -> S.start_link(sp) end)
    end
  end

  describe "Perform auth" do
    test "Makes a token request", %{session: session, token_request_url: token_request_url} do
      S.request_auth_tokens(session)

      assert_received(
        {:http_post,
         %{
           url: token_request_url,
           body: %{
             grant_type: "authorization_code",
             code: @test_code,
             redirect_uri: "http://localhost:3000"
           },
           headers: [{:Authorization, @test_client_token}]
         }}
      )
    end

    test "saves the tokens to server state", %{session: session} do
      S.request_auth_tokens(session)

      assert %{access_token: _, refresh_token: _} = :sys.get_state(session)
    end

    test "saves the scope to server state", %{session: session} do
      S.request_auth_tokens(session)

      assert %{scope: _} = :sys.get_state(session)
    end
  end
end
