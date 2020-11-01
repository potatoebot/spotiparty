code = System.argv() |> hd
IO.inspect({'client_id', Application.get_env(:spotify_adapter, :client_id)})
IO.inspect({'client_secret', Application.get_env(:spotify_adapter, :client_secret)})

{:ok, session} = SpotifyAdapter.Session.start_link(%{code: code})

IO.inspect(:sys.get_state(session))

SpotifyAdapter.Session.request_auth_tokens(session)

IO.inspect(:sys.get_state(session))
