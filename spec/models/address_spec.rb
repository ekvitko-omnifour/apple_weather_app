require "rails_helper"
require "geocoder/results/nominatim"

RSpec.describe Address do
  let(:address) { "Hallandale Beach, FL 33009" }
  let(:geocoder_result) { Geocoder::Result::Nominatim.new(geocoder_data) }
  let(:geocoder_data) do
    {
      "lat" => lat,
      "lon" => lon,
      "address" => address_data
    }
  end
  let(:lat) { "27.2939333" }
  let(:lon) { "-80.3503283" }
  let(:address_data) do
    {
      "postcode" => postal_code,
      "city" => city,
      "state" => state,
      "country" => country
    }
  end
  let(:postal_code) { "33009" }
  let(:city) { "Hallandale Beach" }
  let(:state) { "Florida" }
  let(:country) { "United States" }
  let(:cache_key) { "geocode/#{Digest::MD5.hexdigest(address.downcase.strip)}" }

  before do
    Rails.cache.clear
    allow(Geocoder).to receive(:search).with(address).and_return([ geocoder_result ])
  end

  describe "#initialize" do
    subject { described_class.new(address) }

    it "successfully geocodes and returns coordinates" do
      expect(subject.latitude).to eq(lat.to_f)
      expect(subject.longitude).to eq(lon.to_f)
    end

    it "caches the geocoding result" do
      expect(Rails.cache.exist?(cache_key)).to be(false)

      subject

      expect(Rails.cache.exist?(cache_key)).to be(true)
    end

    it "raises an error if no geocoding result is found" do
      allow(Geocoder).to receive(:search).with(address).and_return([])

      expect { subject }.to raise_error(ArgumentError, "Could not resolve address: #{address}")
    end
  end

  describe "attributes" do
    subject { described_class.new(address) }

    it "returns the zip code" do
      expect(subject.zip_code).to eq(postal_code)
    end

    it "returns the city" do
      expect(subject.city).to eq(city)
    end

    it "returns the state" do
      expect(subject.state).to eq(state)
    end

    it "returns the country" do
      expect(subject.country).to eq(country)
    end

    it "returns a display name including the zip" do
      expect(subject.display_name).to include(postal_code)
    end

    context "when borough is present" do
      let(:address_data) do
        {
          "borough" => borough,
          "city" => city,
          "state" => state,
          "country" => country
        }
      end
      let(:borough) { "Brooklyn" }

      it "returns the borough as the city" do
        expect(subject.city).to eq("Brooklyn")
      end
    end

    context "when the country does not use zip codes" do
      let(:address_data) do
        {
          "city_district" => city,
          "state" => state,
          "country" => country
        }
      end
      let(:city) { "Inkerman" }
      let(:state) { "Queensland" }
      let(:country) { "Australia" }

      it "returns a display name without a zip code" do
        expect(subject.display_name).not_to include(postal_code)
      end
    end
  end
end
