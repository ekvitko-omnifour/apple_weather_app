# frozen_string_literal: true

class Forecast
  attr_reader :temp, :low, :high, :condition, :summary, :extended_forecasts

  def initialize(temp:, low:, high:, condition:, summary:, extended_forecasts:)
    @temp = temp
    @low = low
    @high = high
    @condition = condition
    @summary = summary
    @extended_forecasts = extended_forecasts
  end
end
