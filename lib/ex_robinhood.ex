defmodule ExRobinhood do

  alias Enum, as: E
  alias ExRobinhood.Endpoints

  use HTTPoison.Base

  @client_id "c82SH0WZOsabOXGP2sxqcj34FxkvfnWRZBKlBjFS"

  @headers %{
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip, deflate",
    "Accept-Language" => "en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5",
    "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8",
    "X-Robinhood-API-Version" => "1.0.0",
    "Connection" => "keep-alive",
    "User-Agent" => "Robinhood/823 (iPhone; iOS 7.1.2; Scale/2.00)"
  }

  # ExRobinhood.login("example@example.com", "example_password", "")


  def login(username, password, device_token, mfa_code \\ "") do
    body = URI.encode_query(%{
      "password" => password,
      "username" => username,
      "grant_type" => "password",
      "client_id" => @client_id,
      "expires_in" => "86400",
      "scope" => "internal",
      "device_token" => device_token,
      "mfa_code" => mfa_code
    })
    |> IO.inspect()

    resp = post(Endpoints.login, body, @headers)
    #resp = nil

    case resp do
      {:ok, res} -> res.body |> Jason.decode!() |> IO.inspect()

      {:error, message} ->
        IO.inspect(Jason.decode!(message))
        {:error, message}

      _ -> {:error, "resp could not be processed"}

    end
  end








  """

  def logout

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
