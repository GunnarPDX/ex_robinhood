defmodule ExRobinhood do

  alias Enum, as: E
  alias ExRobinhood.Endpoints
  alias ExRobinhood.Account
  alias ExRobinhood.Rest, as: R

  ## HEADER KEYS
  @client_id "c82SH0WZOsabOXGP2sxqcj34FxkvfnWRZBKlBjFS"

  ## ORDER SIDES
  @buy "buy"
  @sell "sell"

  ## ORDER TRIGGERS
  @immediate "immediate"
  @stop "stop"

  ## ORDER TYPES
  @market "market"
  @limit "limit"

  ## TIME IN FORCE
  @good_for_day "gfd"
  @good_til_cancelled "gtc"



  ##------------------------------------------------------------------------
  ## AUTH
  ##------------------------------------------------------------------------
  @doc """
  Login
  """
  @spec login(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}

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

  defp process_auth_response({:ok, %{"access_token" => access_token, "refresh_token" => refresh_token} = _body}) do
    Account.update(:access_token, access_token)
    Account.update(:refresh_token, refresh_token)

    headers = :headers
              |> Account.get()
              |> Map.merge(%{ "Authorization" => "Bearer " <> access_token}, fn _k, _v1, v2 -> v2 end)

    Account.update(:headers, headers)

    {:ok, "Success"}
  end

  defp process_auth_response({:ok, %{"challenge" => %{"id" => id, "status" => "issued"}} = body}) do
    Account.update(:challenge_id, id)

    IO.inspect(body)

    {:ok, "Challenge Required"}
  end

  defp process_auth_response({:ok, %{"status" => "validated"} = _body}) do
    login_after_challenge()
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
  end



  @doc """
  Logout
  """
  @spec logout :: {:ok, String.t()} | {:error, String.t()}

  def logout do
    refresh_token = Account.get(:refresh_token)

    body = URI.encode_query(%{
      "client_id" => @client_id,
      "token" => refresh_token
    })

    Endpoints.logout
    |> R.post(body)
    #|> handle_logout()

    Account.reset()
    {:ok, "Success"}
  end



  ##------------------------------------------------------------------------
  ## INFO
  ##------------------------------------------------------------------------
  @doc """
  User

  {:ok,
  %{
   "created_at" => "2009-01-11T16:21:03.923311-04:00",
   "email" => "email@example.com",
   "email_verified" => true,
   "first_name" => "First",
   "id" => "1c34187b-eeb0-1a5d-9c6c-bb239a3463eb",
   "id_info" => "https://api.robinhood.com/user/id/",
   "last_name" => "Last",
   "origin" => %{"locality" => "US"},
   "profile_name" => "FirstL12345",
   "url" => "https://api.robinhood.com/user/",
   "username" => "first.last"
  }}
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
  @spec historical_quotes(String.t(), String.t(), String.t(), atom) :: {:ok, map} | {:error, map}
  # E.historical_quotes("nvda", "hour", "week", :regular)

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

  def popularity(id) do
    id
    |> Endpoints.instruments("popularity")
    |> R.get()
  end



  @doc """
  Tickers by Tag
  Args: tag - Tags may include but are not limited to:
      * top-movers
      * etf
      * 100-most-popular
      * mutual-fund
      * finance
      * cap-weighted
      * investment-trust-or-fund
  """

  def tickers_by_tag(tag) do
    tag
    |> Endpoints.tags()
    |> R.get()
  end



  @doc """
  Fundamentals
  """

  def fundamentals(symbol) do
    symbol
    |> Endpoints.fundamentals()
    |> R.get()
  end



  @doc """
  Portfolios
  """

  def portfolios do
    Endpoints.portfolios
    |> R.get()
  end



  @doc """
  Order
  """

  def order(order_id) do
    order_id
    |> Endpoints.orders
    |> R.get()
  end



  @doc """
  Order History
  """

  def order_history do
    Endpoints.orders
    |> R.get()
  end



  @doc """
  Dividends
  """

  def dividends do
    Endpoints.dividends
    |> R.get()
  end



  @doc """
  Positions
  """

  def positions do
    Endpoints.positions
    |> R.get()
  end



  @doc """
  Securities Owned
  """

  def securities_owned do
    Endpoints.positions() <> "?nonzero=true"
    |> R.get()
  end



  ##------------------------------------------------------------------------
  ## ORDERS
  ##------------------------------------------------------------------------
  @doc """
  Place Order
  Args:
      instrument_URL (str): the RH URL for the instrument
      symbol (str): the ticker symbol for the instrument
      order_type (str): 'market' or 'limit'
      time_in_force (:enum:`TIME_IN_FORCE`): 'gfd' or 'gtc' (day or until cancelled)
      trigger (str): 'immediate' or 'stop' enum
      price (float): The share price you'll accept
      stop_price (float): The price at which the order becomes a market or limit order
      quantity (int): The number of shares to buy/sell
      side (str): BUY or sell
  """

  def place_order(
        instrument_url,
        symbol,
        order_type,
        time_in_force,
        trigger,
        price,
        stop_price,
        quantity,
        side
      ) do

    body = %{
      "account" => nil,
      "instrument" => instrument_url,
      "symbol" => symbol,
      "type" => order_type,
      "time_in_force" => time_in_force,
      "trigger" => trigger,
      "price" => price,
      "stop_price" => stop_price,
      "quantity" => quantity,
      "side" => side
    }
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    |> URI.encode_query()

    Endpoints.orders
    |> R.post(body)

    # TODO: add account to agent and get that data on login
    # TODO: Sometimes Robinhood asks for another log-in when placing an order

  end



  @doc """
  Place Market Buy Order
  """

  def place_market_buy_order(instrument_url, symbol, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @immediate, nil, nil, quantity, @buy)



  @doc """
  Place Limit Buy Order
  """

  def place_limit_buy_order(instrument_url, symbol, price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @immediate, price, nil, quantity, @buy)



  @doc """
  Place Stop Loss Buy Order
  """

  def place_stop_loss_buy_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @stop, nil, stop_price, quantity, @buy)



  @doc """
  Place Stop Limit Buy Order
  """

  def place_stop_limit_buy_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @stop, price, stop_price, quantity, @buy)



  @doc """
  Place Market Sell Order
  """

  def place_market_sell_order(instrument_url, symbol, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @immediate, nil, nil, quantity, @sell)



  @doc """
  Place Limit Sell Order
  """

  def place_limit_sell_order(instrument_url, symbol, price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @immediate, price, nil, quantity, @sell)



  @doc """
  Place Stop Loss Sell Order
  """

  def place_stop_loss_sell_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @stop, nil, stop_price, quantity, @sell)



  @doc """
  Place Stop Limit Sell Order
  """

  def place_stop_limit_sell_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @stop, price, stop_price, quantity, @sell)



  @doc """
  Cancel Order
  """

  def cancel_order(order_id) do
    order_id
    |> Endpoints.cancel_order()
    |> R.post(nil)
  end



  # def cancel_all_orders
  # def close_all_positions




  ##------------------------------------------------------------------------
  ## OPTIONS
  ##------------------------------------------------------------------------
  # Options Chain
  # defp options_chain(id) do
  #   Endpoints.chain(id)
  #   |> R.get()
  # end
  #
  # Options
  # def options(stock, expiration_dates, option_type) do
  #   Endpoints.options(chain_id, expiration_dates, option_type)
  #   |> R.get()
  # end
  #
  # def get_option_market_data
  # def options_owned
  # def get_option_marketdata
  # def get_option_chainid
  # def get_option_quote
  # def cancel_option_order
  # def cancel_all_options_orders



  ##------------------------------------------------------------------------
  ## CRYPTO
  ##------------------------------------------------------------------------


end
