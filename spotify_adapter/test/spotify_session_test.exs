defmodule SpotifyAdapter.SessionTest do
  use ExUnit.Case
  alias SpotifyAdapter.FakeHttp
  alias SpotifyAdapter.Session, as: S

  doctest S

  @token_request_url "https://accounts.spotify.com/api/token"
  @test_client_token "barf"
  @test_code "code"

  setup do
    startup_params = %{
      code: @test_code,
      http_client: FakeHttp,
      test_reporting_pid: self(),
      client_token: @test_client_token
    }

    session = start_supervised!({S, startup_params})
    %{session: session, startup_params: startup_params}
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

    test "must include an HTTP client module", %{startup_params: startup_params} do
      sp =
        startup_params
        |> Map.delete(:http_client)

      assert_raise(FunctionClauseError, ~r(no function clause), fn -> S.start_link(sp) end)
    end

    test "must include a client token", %{startup_params: startup_params} do
      sp =
        startup_params
        |> Map.delete(:client_token)

      assert_raise(FunctionClauseError, ~r(no function clause), fn -> S.start_link(sp) end)
    end
  end

  describe "Perform auth" do
    test "Makes a token request", %{session: session} do
      S.request_auth_tokens(session)

      assert_received(
        {:http_post,
         %{
           url: @token_request_url,
           body: %{
             grant_type: "authorization_code",
             code: @test_code,
             redirect_uri: "http://localhost:3000"
           },
           headers: [{:Authorization, @test_client_token}]
         }}
      )
    end
  end
end
