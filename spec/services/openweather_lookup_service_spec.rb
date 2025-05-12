require "rails_helper"
require "geocoder/results/nominatim"

RSpec.describe OpenweatherLookupService do
  describe "#call" do
    subject { described_class.new(address).call }

    let(:address) { Address.new(address_str) }
    let(:address_str) { "Hallandale Beach, FL 33009" }
    let(:geocoder_result) do
      Geocoder::Result::Nominatim.new(
        {
          "lat" => lat,
          "lon" => lon,
          "address" => {
            "postal_code" => postal_code
          }
        }
      )
    end
    let(:lat) { "27.2939333" }
    let(:lon) { "-80.3503283" }
    let(:postal_code) { "33009" }
    let(:api_response_body) do
      file_path = Rails.root.join("spec/fixtures/api_responses/onecall_success.json")
      File.read(file_path)
    end
    let(:base_uri) { OpenweatherLookupService.base_uri }

    before do
      Rails.cache.clear
      stub_const("ENV", ENV.to_hash.merge("OPENWEATHER_API_KEY" => "test-api-key"))
      allow(Geocoder).to receive(:search).with(address_str).and_return([ geocoder_result ])

      stub_request(:get, "#{base_uri}/onecall")
        .with(query: hash_including("lat" => lat, "lon" => lon))
        .to_return(status: 200, body: api_response_body, headers: { "Content-Type" => "application/json" })
    end

    it "returns a Forecast and cache status" do
      forecast, cached = subject

      expect(forecast).to be_a(Forecast)
      expect(forecast.temp).to be_a(Numeric)
      expect(forecast.low).to be < forecast.high
      expect(forecast.high).to be_a(Numeric)
      expect(forecast.condition).to be_a(String)
      expect(forecast.summary).to be_a(String)
      expect(forecast.extended_forecasts).to all(include(:date, :low, :high, :condition, :summary))

      expect(cached).to be(false)
    end

    it "uses a valid forecast cache key" do
      allow(Rails.cache).to receive(:fetch).and_call_original

      subject

      expect(Rails.cache).to have_received(:fetch).with(
        a_string_including("forecast/"),
        hash_including(:expires_in)
      )
    end

    context "when address contains a cached zip code" do
      let(:service) { described_class.new(address) }

      it "returns a Forecast from cache" do
        _, cached = service.call
        _, cached2 = service.call

        expect(cached).to be(false)
        expect(cached2).to be(true)
      end
    end

    context "when the weather API fails" do
      it "raises an error" do
        stub_request(:get, "#{base_uri}/onecall")
          .with(query: hash_including("lat" => lat, "lon" => lon))
          .to_return(status: 500, body: "Internal Server Error")

        expect { subject }.to raise_error("There was an error processing your request!")
      end
    end
  end
end
