defmodule SpotifyAdapter.FakeHttp do
  @moduledoc """
  Test double for HttpPoison
  """

  def post!(url, body, headers) do
    send(self(), {:test, :http_post, %{url: url, body: body}})

    %{
      body:
        %{
          "access_token" => "access_token",
          "scope" => "scope",
          "expires_in" => "expires_in",
          "refresh_token" => "refresh_token"
        }
        |> Jason.encode!()
    }
  end

  def put!(url, body, headers) do
    send(self(), {:test, :http_put, %{url: url, body: body, headers: headers}})

    %{
      body:
        %{
          "access_token" => "access_token",
          "scope" => "scope",
          "expires_in" => "expires_in",
          "refresh_token" => "refresh_token"
        }
        |> Jason.encode!()
    }
  end
end
