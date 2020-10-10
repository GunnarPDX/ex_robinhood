defmodule ExRobinhood.Account do
  use Agent

  @credentials %{
    device_token: "",
    mfa_code: "",
    challenge_id: "",
    username: "",
    password: "",
    refresh_token: "",
    access_token: "",
    headers: %{
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip, deflate",
      "Accept-Language" => "en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5",
      "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8",
      "X-Robinhood-API-Version" => "1.0.0",
      "Connection" => "keep-alive",
      "User-Agent" => "Robinhood/823 (iPhone; iOS 7.1.2; Scale/2.00)"
    }
  }

  def start_link(_),
      do: Agent.start_link(fn -> @credentials end, name: __MODULE__)

  def get,
      do: Agent.get(__MODULE__, fn content -> content end)

  def get(key),
      do: Agent.get(__MODULE__, fn content -> content |> Map.fetch!(key) end)

  def update(key, changes),
      do: Agent.update(__MODULE__, fn content -> content |> Map.replace(key, changes) end)

  defp _update(changes),
      do: Agent.update(__MODULE__, fn content -> changes end)

end