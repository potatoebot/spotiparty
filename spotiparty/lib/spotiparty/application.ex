defmodule Spotiparty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Spotiparty.Repo,
      # Start the Telemetry supervisor
      SpotipartyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Spotiparty.PubSub},
      # Start the Endpoint (http/https)
      SpotipartyWeb.Endpoint
      # Start a worker by calling: Spotiparty.Worker.start_link(arg)
      # {Spotiparty.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spotiparty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpotipartyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
