defmodule ExRobinhood do

  alias Enum, as: E
  alias ExRobinhood.Endpoints
  alias ExRobinhood.Account

  use HTTPoison.Base

  @client_id "c82SH0WZOsabOXGP2sxqcj34FxkvfnWRZBKlBjFS"

  @doc """

  """

  def login(username, password) do
    device_token = UUID.uuid4()
    Account.update(:device_token, device_token)
    Account.update(:username, username)
    Account.update(:password, password)

    body = URI.encode_query(%{
      "password" => password,
      "username" => username,
      "grant_type" => "password",
      "client_id" => @client_id,
      "expires_in" => "86400",
      "scope" => "internal",
      "challenge_type" => "sms",
      "device_token" => device_token,
      "mfa_code" => ""
    })

    headers = Account.get(:headers)
    url = Endpoints.login

    url
    |> post(body, headers)
    |> handle_login()

  end

  defp handle_login({:ok, res}) do
    res.body
    |> Jason.decode!()

  end

  defp handle_login({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end

  defp handle_login(_),
       do: {:error, "resp could not be processed"}


  @doc """

  """

  def challenge(sms_code) do
    challenge_id = Account.get(:challenge_id)
    url = Endpoints.challenge(challenge_id)
    body = URI.encode_query(%{ "response" => sms_code })

    headers = :headers
              |> Account.get()
              |> Map.merge(%{ "X-ROBINHOOD-CHALLENGE-RESPONSE-ID" => challenge_id})

    Account.update(:headers, headers)

    url
    |> post(body, headers)
    |> handle_challenge()

  end

  defp handle_challenge({:ok, res}) do
    res.body
    |> Jason.decode!()

  end

  defp handle_challenge({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end

  defp handle_challenge(_),
       do: {:error, "resp could not be processed"}


  @doc false

  defp login_after_challenge do
    password = Account.get(:password)
    username = Account.get(:username)
    device_token = Account.get(:device_token)

    body = URI.encode_query(%{
      "password" => password,
      "username" => username,
      "grant_type" => "password",
      "client_id" => @client_id,
      "expires_in" => "86400",
      "scope" => "internal",
      "challenge_type" => "sms",
      "device_token" => device_token,
      "mfa_code" => ""
    })

    headers = Account.get(:headers)
    url = Endpoints.login

    url
    |> post(body, headers)
    |> handle_login_after_challenge()

  end

  defp handle_login_after_challenge({:ok, res}) do
    res.body
    |> Jason.decode!()

  end

  defp handle_login_after_challenge({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end

  defp handle_login_after_challenge(_),
       do: {:error, "resp could not be processed"}



  @doc """

  """

  def logout do
    refresh_token = Account.get(:refresh_token)

    body = URI.encode_query(%{
      "client_id": @client_id,
      "token": refresh_token
    })

    headers = Account.get(:headers)

    url = Endpoints.logout

    url
    |> post(body, headers)
    |> handle_logout()

  end

  defp handle_logout({:ok, res}) do
    res.body
    |> Jason.decode!()
  end

  defp handle_logout({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end

  defp handle_logout(_),
       do: {:error, "resp could not be processed"}





  """
  def user

  def investment_profile

  def instruments

  def instrument

  def quote_data

  def get_quote_list

  def get_historical_quotes

  def get_news

  def get_account

  def get_popularity

  def get_tickers_by_tag

  def get_options

  def get_option_market_data

  def options_owned

  def get_option_marketdata

  def get_option_chainid

  def get_option_quote

  def get_fundamentals

  def portfolios

  def order_history

  def dividends

  def positions

  def securities_owned

  def place_market_buy_order

  def place_limit_buy_order

  def place_stop_loss_buy_order

  def place_stop_limit_buy_order

  def place_market_sell_owner

  def place_limit_sell_order

  def place_stop_loss_sell_order

  def place_stop_limit_sell_order

  def submit_sell_order

  def submit_buy_order

  def place_order

  def place_buy_order

  def place_sell_order

  def get_open_orders

  def cancel_order
"""

end
