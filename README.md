# ExRobinhood

A Robinhood API client for Elixir.  Currently under development.

## Installation

The package can be installed by adding `ex_robinhood` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_robinhood, "~> 0.0.0"} # NOT AVAILABLE ON HEX YET !!!
  ]
end
```

#### ex_robinhood uses:
```elixir
{:elixir_uuid, "~> 1.2"} # for generating device tokens
{:jason, "~> 1.2"} # decode responses
{:httpoison, "~> 1.7"} # http client
```

## Usage

```elixir
alias ExRobinhood, as: RH
# Successful response
{:ok, result} = RH.login("email@example.com", "myPassword")

# Unsuccessful response
{:error, reason} = RH.login("badEmail@example.com", "notMyPassword")
```

### Return Values

Requests return a 2-tuple with the standard `:ok` or `:error` status.

# Functions

## Login
#### Used to sign into your Robinhood account
```elixir
def login(username, password)
```

## Challenge
#### Used to submit 2FA verification code
```elixir
def challenge(sms_code)
```

## Logout
#### Used to end your Robinhood session
```elixir
def logout
```

## User
#### Gets user info
```elixir
def user
```
#### returns:
```elixir
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
```

## Investment Profile
#### Gets users investment-profile
```elixir
def investment_profile
```

## Query Instruments
#### Gets instrument by `symbol`, (can be used to get stocks `id`)
```elixir
def query_instruments(stock)
```

## Instruments
#### Gets instrument by `id`
```elixir
def instrument(id)
```

## Quote
#### Gets quote for product by `id`
```elixir
def quote(id)
```

## Quote List
#### Gets quote list for list or comma separated string of products by `id`
```elixir
def quote_list(ids)
```

## Stock Marketdata
#### Gets marketdata for stocks
```elixir
def stock_marketdata(symbols)
```

## Historical Quotes
#### Gets historical quotes for
Args:
- stock (str): stock ticker/s
- interval (str): resolution of data ~~> Values are `5minute`, `10minute`, `hour`, `day`, `week`.
- span (str): length of data ~~> `day`, `week`, `month`, `3month`, `year`, or `5year`.
- bounds (atom ~~> `:extended` | `:regular`): extended or regular trading hours ~~> default is `:regular`
```elixir
def historical_quotes(symbol, interval, span, bounds \\ :regular)
```

## Account
#### Gets account data
```elixir
def account
```

## Popularity
#### Gets a stocks popularity on robinhood by `id`
```elixir
def popularity(id)
```

## Tickers by Tag
#### Gets lists of tickers for selected category
Args: tag - Tags may include but are not limited to:
- `top-movers`
- `etf`
- `100-most-popular`
- `mutual-fund`
- `finance`
- `cap-weighted`
- `investment-trust-or-fund`

```elixir
def tickers_by_tag(tag)
```

## Fundamentals
#### Gets a stocks fundamentals info
```elixir
def fundamentals(symbol)
```

## Portfolios
#### Gets portfolios data
```elixir
def portfolios
```

## Order
#### Gets order by `id`
```elixir
def order(order_id)
```

## Order History
#### Gets your order history
```elixir
def order_history
```

## Dividends
#### Gets your dividends
```elixir
def dividends
```

## Positions
#### Gets your positions
```elixir
def positions
```

## Securities Owned
#### Gets your currently owned securities
```elixir
def securities_owned
```

# Order Functions
Args:
- instrument_url: the RH URL for the instrument (str)
- symbol: the ticker symbol for the instrument (str)
- order_type: 'market' or 'limit'
- time_in_force: 'gfd' or 'gtc' (day or until cancelled) (str)
- trigger: 'immediate' or 'stop' (str)
- price: The share price you'll accept (float)
- stop_price: The price at which the order becomes a market or limit order (float)
- quantity: The number of shares to buy/sell (int)
- side: 'buy' or 'sell' (str)

## Place Market Buy Order
#### used to place market buy order
```elixir
def place_market_buy_order(instrument_url, symbol, quantity, time_in_force \\ "gtc")
```

## Place Limit Buy Order
#### used to place limit buy order
```elixir
def place_limit_buy_order(instrument_url, symbol, price, quantity, time_in_force \\ "gtc")
```

## Place Stop Loss Buy Order
#### used to stop loss buy order
```elixir
def place_stop_loss_buy_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ "gtc")
```

## Place Stop Limit Buy Order
#### used to place limit buy order
```elixir
def place_stop_limit_buy_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ "gtc")
```

## Place Market Sell Order
#### used to place market sell order
```elixir
def place_market_sell_order(instrument_url, symbol, quantity, time_in_force \\ "gtc")
```

## Place Limit Sell Order
#### used to place limit sell order
```elixir
def place_limit_sell_order(instrument_url, symbol, price, quantity, time_in_force \\ "gtc")
```

## Place Stop Loss Sell Order
#### used to place stop loss sell order
```elixir
def place_stop_loss_sell_order(instrument_url, symbol, stop_price, quantity, time_in_force \\ "gtc")
```

## Place Stop Limit Sell Order
#### used to place stop limit sell order
```elixir
def place_stop_limit_sell_order(instrument_url, symbol, price, stop_price, quantity, time_in_force \\ "gtc")
```

## Cancel Order
#### used to cancel an open order
```elixir
def cancel_order(order_id)
```


# MSC...
#### (these shouldn't ever be needed)

## Set Account Data (function)
#### You can run this if it fails to run automatically during login, its needed for placing orders.
```elixir
def set_account_url
```

## Place Order
#### (this shouldn't be used normally) ~~> see: `place_market_buy_order`, `place_limit_sell_order`, `etc...`
#### Used to submit orders
Args:
- instrument_URL: the RH URL for the instrument (str)
- symbol: the ticker symbol for the instrument (str)
- order_type: 'market' or 'limit'
- time_in_force: 'gfd' or 'gtc' (day or until cancelled) (str)
- trigger: 'immediate' or 'stop' (str)
- price: The share price you'll accept (float)
- stop_price: The price at which the order becomes a market or limit order (float)
- quantity: The number of shares to buy/sell (int)
- side: 'buy' or 'sell' (str)
```elixir
def place_order(instrument_url, symbol, order_type, time_in_force, trigger, price, stop_price, quantity, side)
```

## getting device token manually (instructions)

- Go to robinhood.com. Log out if you're already logged in
- Right click > Inspect element
- Click on Network tab
- Enter `token` in the input line at the top where it says "Filter"
- With the network monitor-er open, login to Robinhood
- You'll see two new urls pop up that say "api.robinhood.com" and "/oauth2/token"
- Click the one that's not 0 bytes in size
- Click on Headers, then scroll down to the Request Payload section
- Here, you'll see new JSON parameters for your login. What you'll need here is the device token.
- Make sure you keep this saved
- If using the device_token from this method then 2FA will probably be bypassed.