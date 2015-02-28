require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  include OmniauthHelpers
  before(:each) { @request.env['devise.mapping'] = Devise.mappings[:user] }

  %w(
    developer
    facebook
    twitter
    github
    google_oauth2
  ).each do |provider|
    provider_name = Account.provider_name(provider)
    session_key = "devise.#{provider}_data"

    describe "GET #{provider}" do
      context "with omniauth.auth containing a #{provider_name} auth hash" do
        let(:auth_hash) { provider_auth_hash(provider) }
        before(:each) do
          set_oauth provider, auth_hash
          request.env['omniauth.auth'] = auth_hash
        end
        context 'as a visitor' do
          grant_ability :create, Account

          context 'when AuthenticateWithAccount.call returns with a new user' do
            let(:account) do
              double(
                Accounts::AuthenticateWithAccount,
                user_persisted?: false,
                success_message: Faker::Lorem.sentence
              )
            end
            before(:each) do
              expect(Accounts::AuthenticateWithAccount).to(
                receive(:call).with(auth_hash, provider).and_return(account)
              )
            end

            context 'with a valid request' do
              before(:each) do
                get provider
              end

              it { is_expected.to redirect_to(new_user_registration_path) }
              it 'should set the flash based off the success_message' do
                is_expected.to set_flash[:notice].to(account.success_message)
              end
              it "should set #{session_key} session data" do
                expect(session[session_key]).to be_kind_of(Hash)
              end
            end
          end

          context 'when AuthenticateWithAccount.call returns with a existing user' do
            let(:user) { create :user }
            let(:account) do
              double(
                Accounts::AuthenticateWithAccount,
                user_persisted?: true,
                user: user,
                success_message: Faker::Lorem.sentence
              )
            end
            before(:each) do
              expect(Accounts::AuthenticateWithAccount).to(
                receive(:call).with(auth_hash, provider).and_return(account)
              )
            end

            context 'with a valid request' do
              before(:each) do
                get provider
              end

              it { is_expected.to redirect_to(edit_user_registration_path) }
              it 'should set the flash based off the success_message' do
                is_expected.to set_flash[:notice].to(account.success_message)
              end
              it "should not set #{session_key} session data" do
                expect(session[session_key]).to be_nil
              end
            end
          end

          context 'when AuthenticateWithAccount.call raises a AuthenticateWithAccount::Error' do
            let(:error) do
              Accounts::AuthenticateWithAccount::Error.new(:account_disabled, provider)
            end
            before(:each) do
              expect(Accounts::AuthenticateWithAccount).to(
                receive(:call).with(auth_hash, provider).and_raise(error)
              )
            end

            context 'with a valid request' do
              before(:each) { get provider }

              it { is_expected.to redirect_to(new_user_session_path) }
              it 'should set the flash to alert' do
                is_expected.to set_flash[:alert].to(
                  t('devise.omniauth_callbacks.failure',
                    kind: provider_name,
                    reason: error.message
                  )
                )
              end
            end
          end
        end

        context 'as a user' do
          let(:user) { create(:user) }
          before(:each) { sign_in user }
          grant_ability :create, Account

          context 'when LinkAccountToUser.call returns a successful response' do
            let(:account) do
              double(
                Accounts::LinkAccountToUser,
                success_message: Faker::Lorem.sentence
              )
            end
            before(:each) do
              expect(Accounts::LinkAccountToUser).to(
                receive(:call).with(user, auth_hash, provider).and_return(account)
              )
            end

            context 'with a valid request' do
              before(:each) { get provider }

              it { is_expected.to redirect_to(edit_user_registration_path) }
              it 'should set the flash to notice' do
                is_expected.to set_flash[:notice].to(account.success_message)
              end
            end
          end

          context 'when LinkAccountToUser.call raises a LinkAccountToUser::Error' do
            let(:error) do
              Accounts::LinkAccountToUser::Error.new(:previously_linked, provider)
            end
            before(:each) do
              expect(Accounts::LinkAccountToUser).to(
                receive(:call).with(user, auth_hash, provider).and_raise(error)
              )
            end

            context 'with a valid request' do
              before(:each) { get provider }

              it { is_expected.to redirect_to(edit_user_registration_path) }
              it 'should set the flash to alert' do
                is_expected.to set_flash[:alert].to(
                  t('devise.omniauth_callbacks.failure',
                    kind: provider_name,
                    reason: error.message
                  )
                )
              end
            end
          end
        end
      end
    end
  end
end
