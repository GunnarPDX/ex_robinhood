![alt text](https://github.com/GunnarPDX/ex_robinhood/blob/master/ex_robinhood_logo.svg?raw=true)
# 

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

# Unsuccessful response
{:error, reason} = RH.login("badEmail@example.com", "notMyPassword")

# Successful response
{:ok, "Challenge Required"} = RH.login("email@example.com", "myPassword")

# Submit 2FA sms code
{:ok, "Success"} = RH.challenge("123456")

# Query by symbol
{:ok, stock} = RH.query_instruments("nvda")

```

### Return Values

Requests return a 2-tuple with the standard `:ok` or `:error` status.

# Auth Functions

## Login
#### Used to sign into your Robinhood account
```elixir
def login(username, password)
```

## Challenge
#### Used to submit 2FA verification code as a string
```elixir
def challenge(sms_code)
```

## Logout
#### Used to end your Robinhood session
```elixir
def logout
```

# Account Functions

## Account
#### Gets account data
```elixir
def account
```
returns:
```elixir
{
 :ok,
 %{
   "next" => nil,
   "previous" => nil,
   "results" => [
     %{
       "option_trading_on_expiration_enabled" => true,
       "crypto_buying_power" => "0.0000",
       "cash_held_for_options_collateral" => "0.0000",
       "rhs_stock_loan_consent_status" => "...",
       "cash_management_enabled" => false,
       "account_number" => "XXXXXXXX",
       "unsettled_debit" => "0.0000",
       "locked" => false,
       "eligible_for_drip" => false,
       "eligible_for_cash_management" => true,
       "only_position_closing_trades" => false,
       "deactivated" => false,
       "drip_enabled" => false,
       "user_id" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
       "instant_eligibility" => %{
         "additional_deposit_needed" => "0.0000",
         "compliance_user_major_oak_email" => nil,
         "created_at" => "1920-01-10T00:00:00.000000-04:00",
         "created_by" => nil,
         "reason" => "",
         "reinstatement_date" => nil,
         "reversal" => nil,
         "state" => "ok",
         "updated_at" => nil
       },
       "user" => "api.robinhood.com/user/",
       "unsettled_funds" => "0.0000",
       "type" => "margin",
       "portfolio_cash" => "0.0000",
       "cash_balances" => nil,
       "cash_available_for_withdrawal" => "0.0000",
       "margin_balances" => %{
         "day_trades_protection" => true,
         "crypto_buying_power" => "0.0000",
         "cash_held_for_options_collateral" => "0.0000",
         "instant_used" => "0.0000",
         "start_of_day_overnight_buying_power" => "0.0000",
         "marked_pattern_day_trader_date" => "1920-01-10T00:00:00.000000-04:00",
         "cash_held_for_dividends" => "0.0000",
         "margin_withdrawal_limit" => nil,
         "unsettled_debit" => "0.0000",
         "cash_held_for_restrictions" => "0.0000",
         "funding_hold_balance" => "0.0000",
         "margin_limit" => "0.0000",
         "overnight_buying_power" => "0.0000",
         "day_trade_buying_power" => "0.0000",
         "gold_equity_requirement" => "0.0000",
         "unsettled_funds" => "0.0000",
         "cash_held_for_nummus_restrictions" => "0.0000",
         "portfolio_cash" => "0.0000",
         "eligible_deposit_as_instant" => "0.0000",
         "cash_available_for_withdrawal" => "0.0000",
         "uncleared_nummus_deposits" => "0.0000",
         ...
       },
       "received_ach_debit_locked" => false,
       "uncleared_deposits" => "0.0000",
       "sweep_enabled" => false,
       "withdrawal_halted" => false,
       "active_subscription_id" => nil,
       "cash_held_for_orders" => "0.0000",
       "state" => "active",
       "created_at" => "1920-01-10T00:00:00.000000-04:00",
       "buying_power" => "0.0000",
       "cash" => "0.0000",
       "sma" => "0.0000",
       "eligible_for_fractionals" => true,
       "rhs_account_number" => 123456789,
       "is_pinnacle_account" => true,
       "url" => "https://api.robinhood.com/accounts/XXXXXXXX/",
       "deposit_halted" => false,
       "can_downgrade_to_cash" => "https://api.robinhood.com/accounts/XXXXXXXX/can_downgrade_to_cash/",
       "permanently_deactivated" => false,
       "max_ach_early_access_amount" => "1000.00",
       "sma_held_for_orders" => "0.0000",
       "fractional_position_closing_only" => false,
       ...
     }
   ]
 }}

```

## User
#### Gets user info
```elixir
def user
```
returns:
```elixir
{ 
  :ok,
  %{
    "created_at" => "1920-01-10T00:00:00.000000-04:00",
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
returns:
```elixir
{
 :ok,
 %{
   "annual_income" => "...",
   "interested_in_options" => "...",
   "investment_experience" => "...",
   "investment_experience_collected" => true,
   "investment_objective" => "...",
   "liquid_net_worth" => "...",
   "liquidity_needs" => "...",
   "option_trading_experience" => "...",
   "professional_trader" => "...",
   "risk_tolerance" => "...",
   "source_of_funds" => "...",
   "suitability_verified" => true,
   "tax_bracket" => "...",
   "time_horizon" => "...",
   "total_net_worth" => "...",
   "understand_option_spreads" => "...",
   "updated_at" => "1920-01-10T00:00:00.000000-04:00",
   "user" => "api.robinhood.com/user/"
 }
}
```

## Portfolios
#### Gets portfolios data
```elixir
def portfolios
```
returns:
```elixir
{
 :ok,
 %{
   "results" => [
     %{
       "account" => "https://api.robinhood.com/accounts/XXXXXXXX/",
       "adjusted_equity_previous_close" => "0.0000",
       "adjusted_portfolio_equity_previous_close" => "0.0000",
       "equity" => "0.0000",
       "equity_previous_close" => "0.0000",
       "excess_maintenance" => "0.0000",
       "excess_maintenance_with_uncleared_deposits" => "0.0000",
       "excess_margin" => "0.0000",
       "excess_margin_with_uncleared_deposits" => "0.0000",
       "extended_hours_equity" => "0.0000",
       "extended_hours_market_value" => "0.0000",
       "extended_hours_portfolio_equity" => "0.0000",
       "last_core_equity" => "0.0000",
       "last_core_market_value" => "0.0000",
       "last_core_portfolio_equity" => "0.0000",
       "market_value" => "0.0000",
       "portfolio_equity_previous_close" => "0.0000",
       "start_date" => "1920-01-10T00:00:00.000000-04:00",
       "unwithdrawable_deposits" => "0.0000",
       "unwithdrawable_grants" => "0.0000",
       "url" => "https://api.robinhood.com/portfolios/XXXXXXXX/",
       "withdrawable_amount" => "0.0000"
     }
   ]
 }
}
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

# Product Functions

## Query Instruments
#### Gets instrument by `symbol`, (can be used to get stocks `id`)
```elixir
def query_instruments(stock)
```
returns:
```elixir
{
 :ok,
 %{
   "next" => nil,
   "previous" => nil,
   "results" => [
     %{
       "bloomberg_unique" => "EQ0010169500001000",
       "country" => "US",
       "day_trade_ratio" => "0.2500",
       "default_collar_fraction" => "0.05",
       "fractional_tradability" => "tradable",
       "fundamentals" => "https://api.robinhood.com/fundamentals/AAPL/",
       "id" => "450dfc6d-5510-4d40-abfb-f633b7d9be3e",
       "list_date" => "1990-01-02",
       "maintenance_ratio" => "0.2500",
       "margin_initial_ratio" => "0.5000",
       "market" => "https://api.robinhood.com/markets/XNAS/",
       "min_tick_size" => nil,
       "name" => "Apple Inc. Common Stock",
       "quote" => "https://api.robinhood.com/quotes/AAPL/",
       "rhs_tradability" => "tradable",
       "simple_name" => "Apple",
       "splits" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/splits/",
       "state" => "active",
       "symbol" => "AAPL",
       "tradability" => "tradable",
       "tradable_chain_id" => "7dd906e5-7d4b-4161-a3fe-2c3b62038482",
       "tradeable" => true,
       "type" => "stock",
       "url" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/"
     }
   ]
 }
}
```

## Instruments
#### Gets instrument by `symbol`
```elixir
def instrument(symbol)
```
returns:
```elixir
{
 :ok,
 %{
   "next" => nil,
   "previous" => nil,
   "results" => [
     %{
       "bloomberg_unique" => "EQ0010169500001000",
       "country" => "US",
       "day_trade_ratio" => "0.2500",
       "default_collar_fraction" => "0.05",
       "fractional_tradability" => "tradable",
       "fundamentals" => "https://api.robinhood.com/fundamentals/AAPL/",
       "id" => "450dfc6d-5510-4d40-abfb-f633b7d9be3e",
       "list_date" => "1990-01-02",
       "maintenance_ratio" => "0.2500",
       "margin_initial_ratio" => "0.5000",
       "market" => "https://api.robinhood.com/markets/XNAS/",
       "min_tick_size" => nil,
       "name" => "Apple Inc. Common Stock",
       "quote" => "https://api.robinhood.com/quotes/AAPL/",
       "rhs_tradability" => "tradable",
       "simple_name" => "Apple",
       "splits" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/splits/",
       "state" => "active",
       "symbol" => "AAPL",
       "tradability" => "tradable",
       "tradable_chain_id" => "7dd906e5-7d4b-4161-a3fe-2c3b62038482",
       "tradeable" => true,
       "type" => "stock",
       "url" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/"
     }
   ]
 }
}
```

## Quote
#### Gets quote for product by `id` or `symbol`
```elixir
def quote(id)
```
returns: 
```elixir
{
 :ok,
 %{
   "adjusted_previous_close" => "121.100000",
   "ask_price" => "120.870000",
   "ask_size" => 236,
   "bid_price" => "120.830000",
   "bid_size" => 100,
   "has_traded" => true,
   "instrument" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/",
   "last_extended_hours_trade_price" => "120.850000",
   "last_trade_price" => "121.190000",
   "last_trade_price_source" => "consolidated",
   "previous_close" => "121.100000",
   "previous_close_date" => "2020-10-13",
   "symbol" => "AAPL",
   "trading_halted" => false,
   "updated_at" => "2020-10-14T22:46:28Z"
 }
}
```

## Quote List
#### Gets quote list for list or comma separated string of products by `id` or `symbol` (min: 2 items)
```elixir
def quote_list(ids)
```
returns:
```elixir
{
 :ok,
 %{
   "results" => [
     %{
       "adjusted_previous_close" => "121.100000",
       "ask_price" => "121.100000",
       "ask_size" => 50,
       "bid_price" => "120.920000",
       "bid_size" => 10,
       "has_traded" => true,
       "instrument" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/",
       "last_extended_hours_trade_price" => "121.060000",
       "last_trade_price" => "121.190000",
       "last_trade_price_source" => "consolidated",
       "previous_close" => "121.100000",
       "previous_close_date" => "2020-10-13",
       "symbol" => "AAPL",
       "trading_halted" => false,
       "updated_at" => "2020-10-14T23:13:18Z"
     }, 
     %{
       "adjusted_previous_close" => "222.860000",
       "ask_price" => "220.800000",
       "ask_size" => 6,
       "bid_price" => "220.350000",
       "bid_size" => 1,
       "has_traded" => true,
       "instrument" => "https://api.robinhood.com/instruments/50810c35-d215-4866-9758-0ada4ac79ffa/",
       "last_extended_hours_trade_price" => "220.600000",
       "last_trade_price" => "220.860000",
       "last_trade_price_source" => "consolidated",
       "previous_close" => "222.860000",
       "previous_close_date" => "2020-10-13",
       "symbol" => "MSFT",
       "trading_halted" => false,
       "updated_at" => "2020-10-14T23:12:07Z"
     },
     nil
   ]
 }
}
```


## Stock Marketdata
#### Gets marketdata for stocks
```elixir
def stock_marketdata(symbols) # !
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
returns:
```elixir
{
 :ok,
 %{
   "results" => [
     %{
       "InstrumentID" => "450dfc6d-5510-4d40-abfb-f633b7d9be3e",
       "bounds" => "regular",
       "historicals" => [
         %{
           "begins_at" => "2020-10-14T14:00:00Z",
           "close_price" => "122.120000",
           "high_price" => "122.820000",
           "interpolated" => false,
           "low_price" => "121.180000",
           "open_price" => "122.690700",
           "session" => "reg",
           "volume" => 13558258
         },
         %{
           "begins_at" => "2020-10-14T15:00:00Z",
           "close_price" => "120.815000",
           "high_price" => "122.270000",
           "interpolated" => false,
           "low_price" => "120.720000",
           "open_price" => "122.130000",
           "session" => "reg",
           "volume" => 7667417
         },
         ...
       ],
       "instrument" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/",
       "interval" => "hour",
       "open_price" => "121.000000",
       "open_time" => "2020-10-14T13:30:00Z",
       "previous_close_price" => "121.100000",
       "previous_close_time" => "2020-10-13T20:00:00Z",
       "quote" => "https://api.robinhood.com/quotes/450dfc6d-5510-4d40-abfb-f633b7d9be3e/",
       "span" => "day",
       "symbol" => "AAPL"
     }
   ]
 }
}
```

## Popularity
#### Gets a stocks popularity on robinhood by `id`
```elixir
def popularity(id) # !
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
returns:
```elixir
{
 :ok,
 %{
   "canonical_examples" => "",
   "description" => "",
   "instruments" => [
    "https://api.robinhood.com/instruments/9f1399e5-5023-425a-9eb5-cd3f91560189/",
    "https://api.robinhood.com/instruments/681574a9-a045-490d-a5f2-889f188c4605/",
    "https://api.robinhood.com/instruments/01f5cac5-56e1-46d9-a782-b1a07a3ec3da/",
    "https://api.robinhood.com/instruments/9f91a18c-b34d-4e67-a68b-2c29d20aa99c/",
    "https://api.robinhood.com/instruments/894f3199-42be-4fcd-b725-d29ba4a8e821/",
    "https://api.robinhood.com/instruments/0c7c5024-5431-4068-9034-0b0e2bfb4277/",
    "https://api.robinhood.com/instruments/ece8cb62-ea02-4b9e-92fc-b404af27753f/",
    "https://api.robinhood.com/instruments/8802a289-bdb5-4003-ae33-4dcd54abb1b7/",
    "https://api.robinhood.com/instruments/c241e363-7635-49c4-9f98-a4a144f158eb/",
    "https://api.robinhood.com/instruments/05411449-2743-475e-ab15-2f86e43e06a4/",
    "https://api.robinhood.com/instruments/991a1c9b-6161-4c7a-b6ae-9a710c4fbff3/",
    "https://api.robinhood.com/instruments/ea6bf532-d3ff-4094-9e6b-4fb473b2c702/",
    "https://api.robinhood.com/instruments/52f36ef8-ae45-410d-8af7-0b7aaa2d276c/",
    "https://api.robinhood.com/instruments/33c3c43d-d6b9-4df5-963a-7611acc416e9/",
    "https://api.robinhood.com/instruments/c43ecf94-68e0-4fd8-a2a3-3ab5492ecf30/",
    "https://api.robinhood.com/instruments/082877c8-2cbb-414a-9f46-e57c23b500df/",
    "https://api.robinhood.com/instruments/ead8ebd4-3804-40f1-95ac-7c1b98818f9d/",
    "https://api.robinhood.com/instruments/f551545a-16c0-4561-a44f-d5bcc6d316fc/",
    "https://api.robinhood.com/instruments/8b486a6b-0632-4526-acf7-2167b22d8d94/",
    "https://api.robinhood.com/instruments/3582a151-efd3-4e80-9496-667dfe3c86de/"
    ],
   "membership_count" => 20,
   "name" => "Top Movers",
   "slug" => "top-movers"
 }
}
```

## Fundamentals
#### Gets a stocks fundamentals info
```elixir
def fundamentals(symbol)
```
returns:
```elixir
{
 :ok,
 %{
   "average_volume" => "155470041.000000",
   "average_volume_2_weeks" => "155470041.000000",
   "ceo" => "Timothy Donald Cook",
   "description" => "Apple, Inc. engages in the design, manufacture, and sale of smartphones, personal computers, tablets, wearables and accessories, and other variety of related services. It operates through the following geographical segments: Americas, Europe, Greater China, Japan, and Rest of Asia Pacific. The Americas segment includes North and South America. The Europe segment consists of European countries, as well as India, the Middle East, and Africa. The Greater China segment comprises of China, Hong Kong, and Taiwan. The Rest of Asia Pacific segment includes Australia and Asian countries. Its products and services include iPhone, Mac, iPad, AirPods, Apple TV, Apple Watch, Beats products, Apple Care, iCloud, digital content stores, streaming, and licensing services. The company was founded by Steven Paul Jobs, Ronald Gerald Wayne, and Stephen G. Wozniak on April 1, 1976 and is headquartered in Cupertino, CA.",
   "dividend_yield" => "0.639068",
   "float" => "17320118735.700001",
   "headquarters_city" => "Cupertino",
   "headquarters_state" => "California",
   "high" => "123.030000",
   "high_52_weeks" => "137.980000",
   "industry" => "Telecommunications Equipment",
   "instrument" => "https://api.robinhood.com/instruments/450dfc6d-5510-4d40-abfb-f633b7d9be3e/",
   "low" => "119.620000",
   "low_52_weeks" => "53.152500",
   "market_cap" => "2101107387000.000000",
   "num_employees" => 137000,
   "open" => "121.000000",
   "pb_ratio" => "29.491300",
   "pe_ratio" => "37.819600",
   "sector" => "Electronic Technology",
   "shares_outstanding" => "17337300000.000000",
   "volume" => "150969107.000000",
   "year_founded" => 1976
 }
}
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
#### (these shouldn't be needed)

## Set Account Data
#### You can run this if it fails to run automatically during login, its needed for placing orders.
```elixir
def set_account_url
```

## Place Order
it's easier to use: `place_market_buy_order()`, `place_limit_sell_order()`, `etc...`
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