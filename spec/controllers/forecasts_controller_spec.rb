require "rails_helper"

RSpec.describe ForecastsController, type: :controller do
  describe "POST #create" do
    let(:address_str) { "Brooklyn, NY" }
    let(:address) { instance_double(Address, display_name: "Brooklyn, NY") }
    let(:forecast) { instance_double(Forecast) }

    before do
      allow(Address).to receive(:new).with(address_str).and_return(address)
      allow(OpenweatherLookupService).to receive(:new).with(address)
        .and_return(instance_double(OpenweatherLookupService, call: [ forecast, false ]))
    end

    it "assigns forecast and renders show" do
      post :create, params: { address: address_str }

      expect(assigns(:forecast)).to eq(forecast)
      expect(assigns(:cached)).to be(false)
      expect(response).to render_template(:show)
    end

    context "when address is invalid" do
      let(:arg_error) { "Could not resolve address" }

      before do
        allow(Address).to receive(:new).and_raise(ArgumentError, arg_error)
      end

      it "redirects with alert" do
        post :create, params: { address: address_str }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(arg_error)
      end
    end
  end
end
