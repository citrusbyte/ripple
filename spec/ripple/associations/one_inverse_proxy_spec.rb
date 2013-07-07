require 'spec_helper'

describe Ripple::Associations::OneInverseProxy do

  before do
    @president = User.create(email: 'president@internet.com')
  end

  after do
    Country.destroy_all
    User.destroy_all
  end

  it "should return nil when there are no references to itself" do
    @president.president_of.should be_nil
  end

  it "should return the object who saves the foreign key" do
    country = Country.create name: 'Internet', president_user_id: @president.key
    @president.reload

    @president.president_of.should == country
  end

  it "should return the object who saves the relation" do
    country = Country.create name: 'Internet', president: @president
    @president.reload

    @president.president_of.should == country
  end
end
