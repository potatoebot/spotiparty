defmodule SpotipartyWeb.PageLive do
  @moduledoc false
  use SpotipartyWeb, :live_view

  @impl true
  def mount(_params, _session, socket = %{assigns: %{spotsesh: pid}}) when is_pid(pid) do
    {:ok, socket}
  end

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    adapter = Application.get_env(:spotiparty, :spotify_adapter)
    {:ok, spotsesh} = adapter.start_link(%{code: code})
    adapter.request_auth_tokens(spotsesh)
    {:ok, assign(socket, spotsesh: spotsesh)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, spotsesh: nil)}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not SpotipartyWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end

  defp url do
    "https://accounts.spotify.com/authorize?client_id=#{
      Application.get_env(:spotiparty, :client_id)
    }&response_type=code&redirect_uri=#{Application.get_env(:spotiparty, :base_url)}/callback&scope=user-modify-playback-state"
  end
end
