defmodule SpotipartyWeb.PageLiveTest do
  use SpotipartyWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Phoenix.HTML

  setup do
    Application.put_env(:spotiparty, :test_pid, self())
    {:ok, %{}}
  end

  describe ":new" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/")
      assert disconnected_html =~ "s spotiparty"
      assert render(page_live) =~ "s spotiparty"
    end

    test "has a link to spotify", %{conn: conn} do
      {:ok, page_live, _} = live(conn, "/")
      link_element = page_live |> element("a[data_test=\"connect-link\"]")
      assert render(link_element) =~ "Connect to Spotify"
      assert render(link_element) =~ "https://accounts.spotify.com/authorize"
    end
  end

  describe "callback" do
    test "if callback, don't have the spotify link", %{conn: conn} do
      {:ok, page_live, _} = live(conn, "/callback?code=COWDE")
      link_element = page_live |> element("a[data_test=\"connect-link\"]")
    end

    test "starts a spotify adapter", %{conn: conn} do
      refute_received(:adapter_start)
      {:ok, page_live, _} = live(conn, "/callback?code=COWDE")
      assert_received(:adapter_start)
    end

    test "requests auth tokens", %{conn: conn} do
      refute_received(:adapter_request_tokens)
      {:ok, page_live, _} = live(conn, "/callback?code=COWDE")
      assert_received(:adapter_request_tokens)
    end

    test "display connected if connected", %{conn: conn} do
      {:ok, page_live, _} = live(conn, "/")
      refute render(page_live) =~ "Connected"
      {:ok, page_live, _} = live(conn, "/callback?code=COWDE")
      assert render(page_live) =~ "Connected"
    end
  end
end
