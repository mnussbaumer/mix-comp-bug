defmodule Mix.Tasks.Third.Start do
  use Mix.Task
  require Logger

  @moduledoc """
  Task to start the queues server app.
  This is so that we can start the queues app alone because it will be deployed
  as an individual node.
  """

  @shortdoc """
  Start the queues server.
  """

  @impl true
  def run(_) do
    Logger.warning("""
    \n\n\nStarting :third\n
    BUILD_ROOT: #{System.get_env("MIX_BUILD_ROOT")}
    CONCURRENCY_LOCK: #{System.get_env("MIX_OS_CONCURRENCY_LOCK")}
    MIX_DEPS_PATH: #{System.get_env("MIX_DEPS_PATH")}
    \n\n
    """)

    {:ok, _} = Application.ensure_all_started(:third, :permanent)
    Mix.Tasks.Run.run(["--no-halt", "--no-start", "--no-compile"])
  end
end
