require 'spec_helper'
describe "OathKeeper::Client" do
  it "should return a queryable object" do
    client = OathKeeper::Client.new
    client = client.where(name: "test").desc(:created_at)
    expect(client.selector).to eq({"name"=>"test"})
    expect(client.options).to eq({:sort => {"created_at"=>-1}})
  end

  it "should execute the specified query" do
    client = OathKeeper::Client.new
    client = client.where(name: "test").desc(:created_at)
    expect(client.execute).to be_kind_of(Mongo::Cursor)
  end
end
