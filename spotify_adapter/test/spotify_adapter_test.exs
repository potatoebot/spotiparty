defmodule SpotifyAdapterTest do
  use ExUnit.Case
  doctest SpotifyAdapter

  test "" do
    assert SpotifyAdapter.hello() == :world
  end
end
