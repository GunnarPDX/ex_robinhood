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
  ## Login
  ### Used to sign into your Robinhood account
  Args:
    username: email@example.com
    password: qwerty1234
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

    set_account_url()
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
  ## Challenge
  ### Used to submit 2FA verification code
  Args:
    sms_code: 123123    <~~(string or number)
  """
  @spec challenge(String.t()) :: {:ok, String.t()} | {:error, String.t()}

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
  ## Logout
  ### Used to end your Robinhood session
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
  ## User
  ### Gets user info

  Returns:
  {
    :ok,
    %{
       "created_at" => "2000-01-11T16:21:00.000000-04:00",
       "email" => "email@example.com",
       "email_verified" => true,
       "first_name" => "First",
       "id" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
       "id_info" => "https://api.robinhood.com/user/id/",
       "last_name" => "Last",
       "origin" => %{"locality" => "US"},
       "profile_name" => "FirstL12345",
       "url" => "https://api.robinhood.com/user/",
       "username" => "first.last"
    }
  }
  """
  def user do
    Endpoints.user
    |> R.get()
  end



  @doc """
  ## Investment Profile
  ### Gets users investment-profile
  """

  def investment_profile do
    Endpoints.investment_profile
    |> R.get()
  end



  @doc """
  ## Query Instruments
  ### Gets instrument by `symbol`, (can be used to get stocks `id`)
  """

  def query_instruments(stock) do
    Endpoints.instruments <> "?query=" <> stock
    |> R.get()
  end



  @doc """
  ## Instruments
  ### Gets instrument by `id`
  """

  def instrument(id) do
    Endpoints.instruments <> "?symbol=" <> "#{id}"
    |> R.get()
  end



  @doc """
  ## Quote
  ### Gets quote for product by `id`
  """

  def quote(id) do
    id
    |> Endpoints.quotes()
    |> R.get()
    |> IO.inspect()
  end



  @doc """
  ## Quote List
  ### Gets quote list for list or comma separated string of products by `id`
  """

  def quote_list(ids) when is_list(ids) do
    "?symbols=" <> E.join(ids, ",") <> ",#"
    |> Endpoints.quotes()
    |> R.get()
  end

  def quote_list(ids) when is_binary(ids) do
    "?symbols=" <> ids
    |> Endpoints.quotes()
    |> R.get()
  end



  @doc """
  ## Stock Marketdata
  ### Gets marketdata for stocks
  """

  # TODO: urls as arg?
  def stock_marketdata(symbols) when is_list(symbols) do
    "quotes/?instruments=" <> E.join(symbols, ",")
    |> Endpoints.market_data()
    |> R.get()
  end

  def stock_marketdata(symbols) when is_binary(symbols) do
    "quotes/?instruments=" <> symbols
    |> Endpoints.market_data()
    |> R.get()
  end



  @doc """
  ## Historical Quotes
  ### Gets historical quotes for
  Args:
    stock (str): stock ticker/s
    interval (str): resolution of data ~~> Values are `5minute`, `10minute`, `hour`, `day`, `week`.
    span (str): length of data ~~> `day`, `week`, `month`, `3month`, `year`, or `5year`.
    bounds (atom = `:extended` | `:regular`): extended or regular trading hours [ default is `:regular` ]
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
  ## Account
  ### Gets account data
  """

  def account do
    Endpoints.accounts
    |> R.get()
  end



  @doc """
  ## Set Account Data
  ### (shouldn't ever be needed)
  ### You can run this if it fails to run automatically during login, its needed for placing orders.
  """

  def set_account_url do
    case account() do
      {:ok, %{"results" => [%{"url" => url}]}} ->
        Account.update(:account_url, url)
        {:ok, "success"}

      _ -> {:error, "Account url could not be retrieved, please try calling set_account_url()"}
    end
  end



  @doc """
  ## Popularity
  ### Gets a stocks popularity on robinhood by `id`
  """

  def popularity(id) do
    id
    |> Endpoints.instruments("popularity")
    |> R.get()
  end



  @doc """
  ## Tickers by Tag
  ### Gets lists of tickers for selected category
  Args: tag - Tags may include but are not limited to:
    * `top-movers`
    * `etf`
    * `100-most-popular`
    * `mutual-fund`
    * `finance`
    * `cap-weighted`
    * `investment-trust-or-fund`
  """

  def tickers_by_tag(tag) do
    tag
    |> Endpoints.tags()
    |> R.get()
  end



  @doc """
  ## Fundamentals
  ### Gets a stocks fundamentals info
  """

  def fundamentals(symbol) do
    symbol
    |> Endpoints.fundamentals()
    |> R.get()
  end



  @doc """
  ## Portfolios
  ### Gets portfolios data
  """

  def portfolios do
    Endpoints.portfolios
    |> R.get()
  end



  @doc """
  ## Order
  ### Gets order by `id`
  """

  def order(order_id) do
    order_id
    |> Endpoints.orders
    |> R.get()
  end



  @doc """
  ## Order History
  ### Gets your order history
  """

  def order_history do
    Endpoints.orders
    |> R.get()
  end



  @doc """
  ## Dividends
  ### Gets your dividends
  """

  def dividends do
    Endpoints.dividends
    |> R.get()
  end



  @doc """
  ## Positions
  ### Gets your positions
  """

  def positions do
    Endpoints.positions
    |> R.get()
  end



  @doc """
  ## Securities Owned
  ### Gets your currently owned securities
  """

  def securities_owned do
    Endpoints.positions() <> "?nonzero=true"
    |> R.get()
  end



  ##------------------------------------------------------------------------
  ## ORDERS # TODO: fractional shares
  ##------------------------------------------------------------------------

  @doc """
  ## Place Order
  ### (this shouldn't be used normally) ~~> see: place_market_buy_order, place_limit_sell_order, etc...
  ### Used to submit orders
  Args:
    instrument_URL: the RH URL for the instrument (str)
    symbol: the ticker symbol for the instrument (str)
    order_type: 'market' or 'limit'
    time_in_force: 'gfd' or 'gtc' (day or until cancelled) (str)
    trigger: 'immediate' or 'stop' (str)
    price: The share price you'll accept (float)
    stop_price: The price at which the order becomes a market or limit order (float)
    quantity: The number of shares to buy/sell (int)
    side: 'buy' or 'sell' (str)
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
  ## Place Market Buy Order
  ### used to place market buy order
  """

  def place_market_buy_order(instrument_url, symbol, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @immediate, nil, nil, quantity, @buy)



  @doc """
  ## Place Limit Buy Order
  ### used to place limit buy order
  """

  def place_limit_buy_order(instrument_url, symbol, price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @immediate, price, nil, quantity, @buy)



  @doc """
  ## Place Stop Loss Buy Order
  ### used to stop loss buy order
  """

  def place_stop_loss_buy_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @stop, nil, stop_price, quantity, @buy)



  @doc """
  ## Place Stop Limit Buy Order
  ### used to place limit buy order
  """

  def place_stop_limit_buy_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @stop, price, stop_price, quantity, @buy)



  @doc """
  ## Place Market Sell Order
  ### used to place market sell order
  """

  def place_market_sell_order(instrument_url, symbol, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @immediate, nil, nil, quantity, @sell)



  @doc """
  ## Place Limit Sell Order
  ### used to place limit sell order
  """

  def place_limit_sell_order(instrument_url, symbol, price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @immediate, price, nil, quantity, @sell)



  @doc """
  ## Place Stop Loss Sell Order
  ### used to place stop loss sell order
  """

  def place_stop_loss_sell_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @market, time_in_force, @stop, nil, stop_price, quantity, @sell)



  @doc """
  ## Place Stop Limit Sell Order
  ### used to place stop limit sell order
  """

  def place_stop_limit_sell_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ @good_til_cancelled),
      do: place_order(instrument_url, symbol, @limit, time_in_force, @stop, price, stop_price, quantity, @sell)



  @doc """
  ## Cancel Order
  ### used to cancel an open order
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
