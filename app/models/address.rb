# frozen_string_literal: true

class Address
  attr_reader :raw_address, :location

  def initialize(raw_address)
    @raw_address = raw_address

    # This is a simple caching strategy for a raw address input string from
    # a user, but it is not ideal for production. If there was more time and
    # this was a production app, I would start with normalizing the input
    # of the address using one of several tools. The easiest is using autofill
    # from Google Places and strictly requiring an address to be auto-populated
    # from user input. That would give us much more flexibility in how we cache
    # since the input can then be split up into parts which we can assess when
    # it reaches this instantiation. Having it in parts would allow us to cache
    # by any address structure we please as opposed to a raw input from a user
    # which is absolutely going to vary by user.
    @location = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Geocoder.search(raw_address).first
    end

    # This object would not be functional without valid geocoding so I fail early.
    raise ArgumentError, "Could not resolve address: #{raw_address}" unless location&.coordinates
  end

  def coordinates
    location.coordinates
  end

  def latitude
    coordinates.first
  end

  def longitude
    coordinates.last
  end

  def zip_code
    location.postal_code
  end

  # In certain locations (New York being one of them), an input of an address in
  # Brooklyn will return a city and state of New York, New York. For enhanced
  # readability and accuracy, if Geocoder returns a borough, we prioritize that
  # over the city. On the flipside, if we're dealing with a country like Australia,
  # then we don't have cities. Instead, they have districts which is why I added
  # the fallback at the end for city_district.
  def city
    location.data.dig("address", "borough") || location.city || location.city_district
  end

  def state
    location.state
  end

  def country
    location.country
  end

  # Not every country uses Zip Codes so I'm accounting for that here.
  def display_name
    str = [ city, state, country ].compact.join(", ")
    zip_code ? "#{str} #{zip_code}" : str
  end

  def cache_key
    "geocode/#{Digest::MD5.hexdigest(raw_address.downcase.strip)}"
  end
end
