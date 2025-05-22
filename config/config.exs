# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :db,
  namespace: DB,
  ecto_repos: [DB.Repo]

config :db, DB.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20,
  timeout: 120_000,
  queue_target: 5_000,
  queue_interval: 15_000,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :db, DB.Mailer, adapter: Swoosh.Adapters.Local

config :server,
  ecto_repos: [Server.Repo],
  generators: [context_app: false]

# Configures the endpoint
config :server, Server.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Server.ErrorHTML, json: Server.ErrorJSON],
    layout: false
  ],
  pubsub_server: Server.PubSub,
  live_view: [signing_salt: "GJFwhibm"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.0",
  server: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/server/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../#{System.get_env("MIX_DEPS_PATH", "deps")}", __DIR__)}
  ]

config :server,
  generators: [context_app: false],
  dns_cluster_query: ["tasks.server", {"third", "tasks.third"}],
  MIX_ENV: config_env()

config :third,
  dns_cluster_query: ["tasks.third", {"server", "tasks.server"}],
  MIX_ENV: config_env()

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
