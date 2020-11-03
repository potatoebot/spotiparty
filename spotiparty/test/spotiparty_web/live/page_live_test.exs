defmodule SpotipartyWeb.PageLiveTest do
  use SpotipartyWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Phoenix.HTML

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
