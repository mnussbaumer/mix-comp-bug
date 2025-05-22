defmodule Mix.Tasks.Server.Start do
  use Mix.Task
  require Logger

  @moduledoc """
  Task to start the server app. This is supposed to be run always with --no-halt
  and --no-start, since it's run locally through compose and dev-entrypoint.sh
  This is so that we don't start the queues app because that will be deployed
  as an individual node.
  """

  @shortdoc """
  Start the server.
  """

  @impl true
  def run(_) do
    Application.put_env(:phoenix, :serve_endpoints, true, persistent: true)

    Logger.warning("""
    \n\n\nStarting :server\n
    BUILD_ROOT: #{System.get_env("MIX_BUILD_ROOT")}
    CONCURRENCY_LOCK: #{System.get_env("MIX_OS_CONCURRENCY_LOCK")}
    MIX_DEPS_PATH: #{System.get_env("MIX_DEPS_PATH")}
    \n\n
    """)

    {:ok, _} = Application.ensure_all_started(:server, :permanent)
    Mix.Tasks.Run.run(["--no-halt", "--no-start", "--no-compile"])
  end
end
