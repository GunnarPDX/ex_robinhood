defmodule ExRobinhood do

  alias Enum, as: E
  alias ExRobinhood.Endpoints
  alias ExRobinhood.Account
  alias ExRobinhood.Rest, as: R

  use HTTPoison.Base

  @client_id "c82SH0WZOsabOXGP2sxqcj34FxkvfnWRZBKlBjFS"


  @doc """
  Login
  """
  @spec login(string, string) :: {:ok, string} | {:error, string}

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

    Endpoints.login
    |> R.post(body)
    |> process_auth_response()
  end



  @doc false

  defp process_auth_response({:ok, %{"access_token" => access_token, "refresh_token" => refresh_token} = body}) do
    Account.update(:access_token, access_token)
    Account.update(:refresh_token, refresh_token)
    Account.update(:password, "")
    Account.update(:username, "")

    headers = :headers
              |> Account.get()
              |> Map.merge(%{ "Authorization" => "Bearer " <> access_token}, fn _k, v1, v2 -> v2 end)

    Account.update(:headers, headers)

    {:ok, "Success"}
  end

  defp process_auth_response({:ok, %{"challenge" => %{"id" => id, "status" => "issued"}} = body}) do
    Account.update(:challenge_id, id)

    IO.inspect(body)

    {:ok, "Challenge Required"}
  end

  defp process_auth_response({:ok, %{"status" => "validated"} = body}) do
    login_after_challenge
  end

  defp process_auth_response(body) do
    IO.inspect(body)
    {:error, body}
  end



  @doc """
  Challenge
  """
  #@spec challenge(string) :: {:ok, string} | {:error, string}

  def challenge(sms_code) do
    challenge_id = Account.get(:challenge_id)
    # url = Endpoints.challenge(challenge_id)
    body = URI.encode_query(%{ "response" => "#{sms_code}" })
    headers = :headers
              |> Account.get()
              |> Map.merge(%{"X-ROBINHOOD-CHALLENGE-RESPONSE-ID" => challenge_id}) #, fn _k, v1, v2 -> v2 end)


    Account.update(:headers, headers)

    challenge_id
    |> Endpoints.challenge()
    |> R.post(body)
    |> process_auth_response()
  end


"""
  defp handle_challenge({:ok, res}) do
    body = res.body |> Jason.decode!()

    process_auth_response({:ok, body})
  end

  defp handle_challenge({:error, message}) do
    reason = Jason.decode!(message)
    {:error, reason}
  end
"""



  @doc false

  defp login_after_challenge do
    IO.puts("Logging in after challenge success")
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

    Endpoints.login
    |> R.post(body)
    |> process_auth_response()
    #|> handle_login_after_challenge()
  end



  @doc """
  Logout
  """
  @spec logout :: {:ok, string} | {:error, string}

  def logout do
    refresh_token = Account.get(:refresh_token)

    body = URI.encode_query(%{
      "client_id": @client_id,
      "token": refresh_token
    })

    Endpoints.logout
    |> R.post(body)
    #|> handle_logout()

    Account.reset()
    {:ok, "Success"}
  end



  @doc """
  User
  """
  def user do
    Endpoints.user
    |> R.get()
  end



  @doc """
  Investment Profile
  """

  def investment_profile do
    #TODO: returns binary ??? !!!
    Endpoints.investment_profile
    |> R.get()
  end



  @doc """
  Query Instruments
  """

  def query_instruments(stock) do
    #TODO: returns binary ??? !!!
    Endpoints.instruments <> "?query=" <> stock
    |> R.get()
  end



  @doc """
  Instruments
  """

  def instrument(id) do
    Endpoints.instruments <> "?symbol=" <> "#{id}"
    |> R.get()
  end



  @doc """
  Quote
  """

  def quote(id) do
    id
    |> Endpoints.quotes()
    |> R.get()
    |> IO.inspect()
  end



  @doc """
  Get Quote List
  """

  def quote_list(ids) when is_list(ids) do
    "?symbols=" <> E.join(ids, ",")
    |> Endpoints.quotes()
    |> R.get()
  end

  def quote_list(ids) when is_binary(ids) do
    "?symbols=" <> ids
    |> Endpoints.quotes()
    |> R.get()
  end



  @doc """
  Get Quote List
  """

  # TODO: symbols or ids?
  def stock_marketdata(symbols) do
    "quotes/?instruments=" <> E.join(symbols, ",")
    |> Endpoints.market_data()
    |> R.get()
  end



  @doc """
  Historical Quotes

  Args:
      stock (str): stock ticker/s
      interval (str): resolution of data -> Values are '5minute', '10minute', 'hour', 'day', 'week'. Default is 'hour'.
      span (str): length of data -> 'day', 'week', 'month', '3month', 'year', or '5year'. Default is 'week'.
      bounds (atom = :extended | :regular): extended or regular trading hours [ default is :regular ]
  """
  @spec historical_quotes(string, string, string, atom) :: {:ok, map} | {:error, map}
  # E.historical_quotes("nvda", "hour", "week", :regular)

  def historical_quotes(symbol, interval, span, bounds)

  def historical_quotes(symbol, interval, span),
      do: historical_quotes(symbol, interval, span, :regular)

  def historical_quotes(symbol, interval, span, :regular) do
    "/?symbols=" <> String.upcase(symbol) <> "&interval=" <> "#{interval}" <> "&span=" <> "#{span}" <> "&bounds=regular"
    |> Endpoints.historicals()
    |> R.get
  end

  def historical_quotes(symbol, interval, span, :extended) do
    "/?symbols=" <> String.upcase(symbol) <> "&interval=" <> "#{interval}" <> "&span=" <> "#{span}" <> "&bounds=extended"
    |> Endpoints.historicals()
    |> R.get
  end



  @doc """
  Account
  """

  def account do
    Endpoints.accounts
    |> R.get()
  end



  @doc """
  Popularity
  """

  def popularity do
    nil
  end



  """


  def popularity

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
