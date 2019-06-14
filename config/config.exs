# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :presence_chat,
  ecto_repos: [PresenceChat.Repo],
  generators: [binary_id: true]

  # Configures the endpoint
config :presence_chat, PresenceChatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lKhsn+8ysEtvTYHzr1MHZa1Z3YB9njKJv30L/mZbb1rWXTsyBDayl1VyVj4yn6ud",
  render_errors: [view: PresenceChatWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PresenceChat.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "E+TvaCigjtXNh6d2rXPu7iktsa2+nkxLHvDHtGHK2ofdVHAedrLaL6p1AxBo4V7j"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
