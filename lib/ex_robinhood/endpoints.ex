defmodule ExRobinhood.Endpoints do

  @moduledoc """
  Documentation for `ExRobinhood`.`Endpoints`

  Functions return endpoint for req
  """

  @api_url "https://api.robinhood.com"

  def login,
      do: "#{@api_url}/oauth2/token/"

  def challenge(challenge_id),
      do: "#{@api_url}/challenge/#{challenge_id}/respond/"

  def logout,
      do: "#{@api_url}/oauth2/revoke_token/"

  def investment_profile,
      do: "#{@api_url}/user/investment_profile/"

  def accounts,
      do: "#{@api_url}/accounts/"

  def ach("iav"),
      do: "#{@api_url}/ach/iav/auth/"

  def ach(option),
      do: "#{@api_url}/ach/#{option}/"

  def applications,
      do: "#{@api_url}/applications/"

  def dividends,
      do: "#{@api_url}/dividends/"

  def edocuments,
      do: "#{@api_url}/documents/"

  def instruments(instrument_id \\ "", option \\ ""),
      do: "#{@api_url}/instruments/#{if instrument_id == "", do: "", else: instrument_id <> "/" }#{if option == "", do: "", else: option <> "/" }"

  def margin_upgrades,
      do: "#{@api_url}/margin/upgrades/"

  def markets,
      do: "#{@api_url}/markets/"

  def notifications,
      do: "#{@api_url}/notifications/"

  def orders(order_id),
      do: "#{@api_url}/orders/#{order_id}"

  def password_reset,
      do: "#{@api_url}/password_reset/request/"

  def portfolios,
      do: "#{@api_url}/portfolios/"

  def positions,
      do: "#{@api_url}/positions/"

  def quotes(symbol),
      do: "#{@api_url}/quotes/#{symbol}/"

  def historicals(params),
      do: "#{@api_url}/quotes/historicals/#{params}"

  def document_requests,
      do: "#{@api_url}/upload/document_requests/"

  def user,
      do: "#{@api_url}/user/"

  def watchlists,
      do: "#{@api_url}/watchlists/"

  def news(stock),
      do: "#{@api_url}/midlands/news/#{stock}/"

  def fundamentals(stock),
      do: "#{@api_url}/fundamentals/#{stock}/"

  def tag(tag),
      do: "#{@api_url}/midlands/tags/tag/#{tag}/"

  def options_base,
      do: "#{@api_url}/options/"

  def chain(instrument_id),
      do: "#{@api_url}/options/chains/?equity_instrument_ids=#{instrument_id}"

  def options(chain_id, dates, option_type),
      do: "#{@api_url}/options/instruments/?chain_id=#{chain_id}&expiration_dates=#{dates}&state=active&tradability=tradable&type=#{option_type}"

  def market_data(symbols),
      do: "#{@api_url}/marketdata/#{symbols}/"

  def option_market_data(option_id),
      do: "#{@api_url}/marketdata/options/#{option_id}/"

  def convert_token,
      do: "#{@api_url}/oauth2/migrate_token/"

end