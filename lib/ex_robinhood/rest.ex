defmodule ExRobinhood.Rest do
  @moduledoc false

  alias ExRobinhood.Account

  @doc false

  def get(url) do
    headers = Account.get(:headers)
    url
    |> HTTPoison.get(headers)
    |> handle_resp()
  end


  @doc false

  def post(url, body) do
    headers = Account.get(:headers)
    HTTPoison.post(url, body, headers)
  end


  @doc false

  defp handle_resp({:ok, resp}) do
    body = Jason.decode!(resp.body)
    {:ok, body}
  end

  defp handle_resp({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end

end