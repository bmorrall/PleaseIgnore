require 'spec_helper'

describe Users::OmniauthCallbacksController do
  include OmniauthHelpers
  before(:each) { @request.env["devise.mapping"] = Devise.mappings[:user] }

  [
    :facebook,
    :twitter,
    :github,
    :google_oauth2,
  ].each do |provider|
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
          context 'with no existing account' do
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { should redirect_to(new_user_registration_path) }
              it { should set_the_flash[:notice].to("Successfully connected to your #{provider_name} account. Please review your details.") }
              it "should set #{session_key} session data" do
                expect(session[session_key]).not_to be_empty
              end
            end
            it 'should not create a new Account' do
              expect {
                get provider
              }.to_not change(Account, :count)
            end
          end
          context 'with a previously linked account' do
            let(:existing_user) { FactoryGirl.create(:user) }
            before(:each) do
              FactoryGirl.create(:"#{provider}_account", uid: auth_hash.uid, user: existing_user)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { should redirect_to(root_path) }
              it { should set_the_flash[:notice].to("Successfully authenticated from your #{provider_name} account.") }
              it "should not set #{session_key} session data" do
                expect(session[session_key]).to be_nil
              end
            end
            it 'should not create a new Account' do
              expect {
                get provider
              }.to_not change(Account, :count)
            end
          end
          context 'with a disabled account' do
            before(:each) do
              account = FactoryGirl.build_stubbed(:"#{provider}_account")
              allow(account).to receive(:enabled?).and_return(false)
              allow(Account).to receive(:find_for_oauth).and_return(account)
            end
            context 'with a valid request' do
              before(:each) { get provider }
              it { should redirect_to(new_user_session_path) }
              it { should set_the_flash[:alert].to("Could not authenticate you from #{provider_name} because \"This account has been disabled\".") }
            end
          end
        end
        context 'as a user' do
          let(:user) { FactoryGirl.create(:user) }
          before(:each) { sign_in user }

          context 'with no existing account' do
            context 'with a valid request' do
              before(:each) { get provider }
              it { should redirect_to(edit_user_registration_path) }
              it { should set_the_flash[:notice].to("Successfully connected to your #{provider_name} account.") }
            end
            it 'should create a Account belonging to the user' do
              expect {
                get provider
              }.to change(Account, :count).by(1)
              expect(Account.last.user).to eq(user)
            end
          end
          context 'with a previously linked account' do
            before(:each) do
              FactoryGirl.create(:"#{provider}_account", uid: auth_hash.uid, user: user)
            end
            it 'should not create a new Account' do
              expect {
                get provider
              }.to_not change(Account, :count)
            end
          end
          context 'with a account linked to another user' do
            before(:each) do
              FactoryGirl.create(:"#{provider}_account", uid: auth_hash.uid)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { should redirect_to(edit_user_registration_path) }
              it { should set_the_flash[:alert].to("Could not authenticate you from #{provider_name} because \"Someone has already linked to this account\".") }
            end
            it 'should not create a new Account' do
              expect {
                get provider
              }.to_not change(Account, :count)
            end
          end
        end
      end
    end
  end

  describe 'GET developer' do
    context 'with omniauth.auth containing a Developer auth hash' do
      let(:auth_hash) { developer_auth_hash }
      before(:each) do
        set_oauth :developer, auth_hash
        request.env['omniauth.auth'] = auth_hash
      end
      context 'as a visitor' do
        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { should redirect_to(new_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully connected to your Developer account. Please review your details.') }
            it 'should set devise.developer_data session data' do
              expect(session['devise.developer_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect {
              get :developer
            }.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { FactoryGirl.create(:user) }
          before(:each) do
            FactoryGirl.create(:account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { should redirect_to(new_user_session_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Developer because "Authentication is disabled from this Provider".') }
            it 'should not set devise.developer_data session data' do
              expect(session['devise.developer_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect {
              get :developer
            }.to_not change(Account, :count)
          end
        end
      end
      context 'as a user' do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { sign_in user }

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully connected to your Developer account.') }
          end
          it 'should create a Account belonging to the user' do
            expect {
              get :developer
            }.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            FactoryGirl.create(:account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect {
              get :developer
            }.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            FactoryGirl.create(:account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Developer because "Someone has already linked to this account".') }
          end
          it 'should not create a new Account' do
            expect {
              get :developer
            }.to_not change(Account, :count)
          end
        end
      end
    end
  end

end

