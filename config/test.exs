import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :db, DB.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "db_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :server, Server.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Wj1iP89FFtADzvAvk8W3eshb15MXINVMAKTBrW0HIvFTfwqbQ33AD4FWx8WfnCM+",
  server: false
