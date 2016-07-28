require File.expand_path('../active_record_spec_helper', __FILE__)

class GenericController < ActionController::Base
  def index
    render :nothing => true
  end

  private

  attr_accessor :current_user
  attr_accessor :custom_user
end

describe GenericController, :adapter => :active_record do
  include RSpec::Rails::ControllerExampleGroup

  context "oathkeeper disabled" do
    before(:each) do
      OathKeeper.clear_storage
      disable_oathkeeper
    end

    it "should have oathkeeper disabled" do
      get :index

      OathKeeper.enabled?.should eq(false)
    end

    it "should not store request info" do
      get :index

      OathKeeper.current_request_group.should eq(nil)
    end

    it "should not write an audit" do
      OathKeeper::Adapter.should_not_receive("write")

      get :index
    end
  end

  context "oathkeeper enabled" do
    before(:each) do
      enable_oathkeeper
    end

    it "should be enabled" do
      expect(OathKeeper.enabled?).to eq(true)
    end

    describe "watch_request" do
    end

    describe "request_end" do
    end

    describe "user_audit" do
    end
  end
end
