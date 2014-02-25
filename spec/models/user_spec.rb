require 'spec_helper'

describe User do

  describe '.new_with_session' do
    context 'with developer auth session data' do
      let(:developer_data) do
        OmniAuth::AuthHash.new({
          :provider => 'developer',
          :uid => 'developer@example.com',
          :info => {
            :name => 'Test Developer',
            :email => 'developer@example.com'
          }
        })
      end
      let(:session) do
        {
          'devise.developer_data' => developer_data
        }
      end
      it 'builds a new user with pre-populated details' do
        user = User.new_with_session({}, session)
        user.name.should eq('Test Developer')
        user.email.should eq('developer@example.com')
      end
      it 'it creates a new account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!

        user.accounts.count.should be(1)
      end
    end
  end

  it { should validate_presence_of(:name) }

  describe '#facebook_login?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      subject.facebook_login?.should be_false 
    end
    it 'returns true with a facebook account' do
      FactoryGirl.create(:facebook_account, user: subject)
      subject.facebook_login?.should be_true
    end
  end

  describe '#github_login?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      subject.github_login?.should be_false 
    end
    it 'returns true with a google account' do
      FactoryGirl.create(:github_account, user: subject)
      subject.github_login?.should be_true
    end
  end

  describe '#google_login?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      subject.google_login?.should be_false 
    end
    it 'returns true with a google account' do
      FactoryGirl.create(:google_account, user: subject)
      subject.google_login?.should be_true
    end
  end

  describe '#twitter_login?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      subject.twitter_login?.should be_false 
    end
    it 'returns true with a twitter account' do
      FactoryGirl.create(:twitter_account, user: subject)
      subject.twitter_login?.should be_true
    end
  end

  # terms_and_conditions
  it { should validate_acceptance_of(:terms_and_conditions) }

end
