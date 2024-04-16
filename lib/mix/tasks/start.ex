defmodule Mix.Tasks.Start do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:hackney)

    JazExTreme.run()
  end
end
