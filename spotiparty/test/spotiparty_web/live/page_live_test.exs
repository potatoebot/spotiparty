defmodule SpotipartyWeb.PageLiveTest do
  use SpotipartyWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Phoenix.HTML

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "s spotiparty"
    assert render(page_live) =~ "s spotiparty"
  end
end
