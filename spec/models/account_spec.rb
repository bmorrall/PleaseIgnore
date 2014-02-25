require 'spec_helper'

describe Account do

  it { should belong_to(:user) }

  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it 'should validate uniqueness of uid scoped to provider' do
    FactoryGirl.create(:account)
    should validate_uniqueness_of(:uid).scoped_to(:provider)
  end
  it { should validate_presence_of(:user_id) }

  it { should allow_value('developer').for(:provider) }
  it { should allow_value('facebook').for(:provider) }
  it { should allow_value('github').for(:provider) }
  it { should allow_value('google_oauth2').for(:provider) }
  it { should allow_value('twitter').for(:provider) }
end
