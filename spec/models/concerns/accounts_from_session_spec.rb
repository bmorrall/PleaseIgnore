require 'rails_helper'

describe Concerns::AccountsFromSession, type: :model do
  subject { User.new }

  describe '.new_with_session' do
    Account.omniauth_providers.each do |provider|
      provider_name = Account.provider_name(provider)

      context "with #{provider_name} auth_session_data" do
        let(:auth_hash) { create :"#{provider}_auth_hash" }
        let(:session) { { "devise.#{provider}_data" => auth_hash } }
        it 'builds a new user using values from the auth hash' do
          user = User.new_with_session({}, session)
          expect(user.name).to eq(auth_hash.info.name)
          expect(user.email).to eq(auth_hash.info.email) unless provider == :twitter
        end
        context 'with valid user params' do
          let(:user_params) { attributes_for(:user) }

          it 'builds a valid user' do
            user = User.new_with_session(user_params, session)
            expect(user).to be_valid
          end

          it 'populates #new_session_accounts with a new account' do
            user = User.new_with_session(user_params, session)
            new_sessions = user.new_session_accounts
            expect(new_sessions.count).to eq(1)
            expect(new_sessions.first).to be_kind_of(Account)
          end

          it "creates a new #{provider_name} account on save" do
            expect do
              user = User.new_with_session(user_params, session)
              user.save!
            end.to change(Account, :count).by(1)

            expect(Account.last.provider).to eq provider
          end
        end
        context 'with invalid account data' do
          let(:user) do
            user_params = attributes_for(:user)
            User.new_with_session(user_params, session)
          end
          before(:each) do
            expect_any_instance_of(Account).to receive(:valid?).and_return(false)
          end

          it 'does not create a new Account on save' do
            expect do
              user.save
            end.to_not change(Account, :count)
          end
          it 'does not create a new User on save' do
            expect do
              user.save
            end.to_not change(User, :count)
          end
          it 'adds an error to the User on save' do
            user_params = attributes_for(:user)
            user = User.new_with_session(user_params, session)
            user.save

            expected = "Unable to add your #{provider_name} account"
            expect(user.errors.messages[:base]).to include expected
          end
        end
      end
    end
  end
end
