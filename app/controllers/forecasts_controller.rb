# frozen_string_literal: true

class ForecastsController < ApplicationController
  def new; end

  def create
    @address = Address.new(address_param)
    @forecast, @cached = OpenweatherLookupService.new(@address).call

    render :show
  rescue ArgumentError => e
    redirect_to root_path, alert: e.message
  end

  private

  def address_param
    params.require(:address)
  end
end
