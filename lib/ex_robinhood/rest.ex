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

    url
    |> HTTPoison.post(body, headers)
    |> handle_resp()
  end


  @doc false

  defp handle_resp({:ok, resp}) do
    body = resp.headers
           |> decode_response_content(resp.body)
           |> Jason.decode!()

    {:ok, body}
  end

  defp handle_resp({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end


  @doc false

  def decode_response_content(headers, body) do
    gzipped = Enum.any?(headers, fn (kv) ->
      case kv do
        {"Content-Encoding", "gzip"} -> true
        {"Content-Encoding", "x-gzip"} -> true
        _ -> false
      end
    end)

    html_body = if gzipped, do: :zlib.gunzip(body), else: body


    html_body
  end

end