defmodule ExRobinhood.Application do
  use Application
  alias ExRobinhood.Account

  def start(_type, _args) do

    children = [
      {Account, 0}
    ]
    opts = [
      strategy: :one_for_one,
      name: ExRobinhood.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end