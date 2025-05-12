# frozen_string_literal: true

class OpenweatherLookupService
  include HTTParty
  base_uri "https://api.openweathermap.org/data/3.0"

  attr_reader :address

  def initialize(address)
    @address = address
  end

  def call
    cached = Rails.cache.exist?(cache_key)
    forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) { retrieve_forecast }

    [ forecast, cached ]
  end

  private

  def retrieve_forecast
    response = fetch_forecast_response

    build_forecast_from_response(response)
  end

  def fetch_forecast_response
    response = self.class.get("/onecall", query: {
      lat: address.latitude,
      lon: address.longitude,
      units: "imperial",
      exclude: "minutely,hourly,alerts",
      appid: ENV["OPENWEATHER_API_KEY"]
    })

    raise "There was an error processing your request!" unless response.success?

    response
  end

  def build_forecast_from_response(response)
    current = response["current"]
    daily = response["daily"]
    today = daily.shift

    Forecast.new(
      temp: current["temp"],
      low: today["temp"]["min"],
      high: today["temp"]["max"],
      condition: current["weather"]&.first&.dig("description"),
      summary: today["summary"],
      extended_forecasts: daily.map do |day|
        {
          date: Time.at(day["dt"]).strftime("%A %m/%d"),
          low: day["temp"]["min"],
          high: day["temp"]["max"],
          condition: day["weather"]&.first&.dig("description"),
          summary: day["summary"]
        }
      end
    )
  end

  # I know the project requirements were specific about caching by zip codes
  # however, zip codes may not always be feasible. In those cases, I added the
  # fallback for the cache key to be the slug of the address display name.
  def cache_key
    @cache_key ||= "forecast/#{address.zip_code.presence || address.normalized_display_slug}"
  end
end
