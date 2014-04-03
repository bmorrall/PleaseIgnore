require 'spec_helper'

describe Users::OmniauthCallbacksController do
  include OmniauthHelpers
  before(:each) { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'GET facebook' do
    context 'with omniauth.auth containing a Facebook auth hash' do
      let(:auth_hash) { facebook_auth_hash }
      before(:each) do
        set_oauth :facebook, auth_hash
        request.env['omniauth.auth'] = auth_hash
      end
      context 'as a visitor' do
        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :facebook
            end
            it { should redirect_to(new_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Facebook account.') }
            it 'should set devise.facebook_data session data' do
              expect(session['devise.facebook_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect {
              get :facebook
            }.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { FactoryGirl.create(:user) }
          before(:each) do
            FactoryGirl.create(:facebook_account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :facebook
            end
            it { should redirect_to(root_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Facebook account.') }
            it 'should not set devise.facebook_data session data' do
              expect(session['devise.facebook_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect {
              get :facebook
            }.to_not change(Account, :count)
          end
        end
        context 'with a disabled account' do
          before(:each) do
            account = Account.new
            allow(account).to receive(:enabled?).and_return(false)
            allow(Account).to receive(:find_for_oauth).and_return(account)
          end
          context 'with a valid request' do
            before(:each) { get :facebook }
            it { should redirect_to(new_user_session_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Facebook because "This account has been disabled".') }
          end
        end
      end
      context 'as a user' do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { sign_in user }

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) { get :facebook }
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Facebook account.') }
          end
          it 'should create a Account belonging to the user' do
            expect {
              get :facebook
            }.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            FactoryGirl.create(:facebook_account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect {
              get :facebook
            }.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            FactoryGirl.create(:facebook_account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :facebook
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Facebook because "Someone has already linked to this account".') }
          end
          it 'should not create a new Account' do
            expect {
              get :facebook
            }.to_not change(Account, :count)
          end
        end
      end
    end
  end

  describe 'GET github' do
    context 'with omniauth.auth containing a GitHub auth hash' do
      let(:auth_hash) { github_auth_hash }
      before(:each) do
        set_oauth :github, auth_hash
        request.env['omniauth.auth'] = auth_hash
      end
      context 'as a visitor' do
        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :github
            end
            it { should redirect_to(new_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from GitHub account.') }
            it 'should set devise.github_data session data' do
              expect(session['devise.github_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect {
              get :github
            }.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { FactoryGirl.create(:user) }
          before(:each) do
            FactoryGirl.create(:github_account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :github
            end
            it { should redirect_to(root_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from GitHub account.') }
            it 'should not set devise.github_data session data' do
              expect(session['devise.github_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect {
              get :github
            }.to_not change(Account, :count)
          end
        end
        context 'with a disabled account' do
          before(:each) do
            account = Account.new
            allow(account).to receive(:enabled?).and_return(false)
            allow(Account).to receive(:find_for_oauth).and_return(account)
          end
          context 'with a valid request' do
            before(:each) { get :github }
            it { should redirect_to(new_user_session_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from GitHub because "This account has been disabled".') }
          end
        end
      end
      context 'as a user' do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { sign_in user }

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :github
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from GitHub account.') }
          end
          it 'should create a Account belonging to the user' do
            expect {
              get :github
            }.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            FactoryGirl.create(:github_account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect {
              get :github
            }.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            FactoryGirl.create(:github_account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :github
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from GitHub because "Someone has already linked to this account".') }
          end
          it 'should not create a new Account' do
            expect {
              get :github
            }.to_not change(Account, :count)
          end
        end
      end
    end
  end

  describe 'GET google_oauth2' do
    context 'with omniauth.auth containing a Google auth hash' do
      let(:auth_hash) { google_auth_hash }
      before(:each) do
        set_oauth :google_oauth2, auth_hash
        request.env['omniauth.auth'] = auth_hash
      end
      context 'as a visitor' do
        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :google_oauth2
            end
            it { should redirect_to(new_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Google account.') }
            it 'should set devise.google_oauth2_data session data' do
              expect(session['devise.google_oauth2_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect {
              get :google_oauth2
            }.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { FactoryGirl.create(:user) }
          before(:each) do
            FactoryGirl.create(:google_account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :google_oauth2
            end
            it { should redirect_to(root_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Google account.') }
            it 'should not set devise.google_oauth2_data session data' do
              expect(session['devise.google_oauth2_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect {
              get :google_oauth2
            }.to_not change(Account, :count)
          end
        end
        context 'with a disabled account' do
          before(:each) do
            account = Account.new
            allow(account).to receive(:enabled?).and_return(false)
            allow(Account).to receive(:find_for_oauth).and_return(account)
          end
          context 'with a valid request' do
            before(:each) { get :google_oauth2 }
            it { should redirect_to(new_user_session_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Google because "This account has been disabled".') }
          end
        end
      end
      context 'as a user' do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { sign_in user }

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :google_oauth2
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Google account.') }
          end
          it 'should create a Account belonging to the user' do
            expect {
              get :google_oauth2
            }.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            FactoryGirl.create(:google_account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect {
              get :google_oauth2
            }.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            FactoryGirl.create(:google_account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :google_oauth2
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Google because "Someone has already linked to this account".') }
          end
          it 'should not create a new Account' do
            expect {
              get :google_oauth2
            }.to_not change(Account, :count)
          end
        end
      end
    end
  end

  describe 'GET twitter' do
    context 'with omniauth.auth containing a Twitter auth hash' do
      let(:auth_hash) { twitter_auth_hash }
      before(:each) do
        set_oauth :twitter, auth_hash
        request.env['omniauth.auth'] = auth_hash
      end
      context 'as a visitor' do
        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :twitter
            end
            it { should redirect_to(new_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Twitter account.') }
            it 'should set devise.twitter_data session data' do
              expect(session['devise.twitter_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect {
              get :twitter
            }.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { FactoryGirl.create(:user) }
          before(:each) do
            FactoryGirl.create(:twitter_account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :twitter
            end
            it { should redirect_to(root_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Twitter account.') }
            it 'should not set devise.twitter_data session data' do
              expect(session['devise.twitter_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect {
              get :twitter
            }.to_not change(Account, :count)
          end
        end
        context 'with a disabled account' do
          before(:each) do
            account = Account.new
            allow(account).to receive(:enabled?).and_return(false)
            allow(Account).to receive(:find_for_oauth).and_return(account)
          end
          context 'with a valid request' do
            before(:each) { get :twitter }
            it { should redirect_to(new_user_session_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Twitter because "This account has been disabled".') }
          end
        end
      end
      context 'as a user' do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { sign_in user }

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :twitter
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:notice].to('Successfully authenticated from Twitter account.') }
          end
          it 'should create a Account belonging to the user' do
            expect {
              get :twitter
            }.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            FactoryGirl.create(:twitter_account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect {
              get :twitter
            }.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            FactoryGirl.create(:twitter_account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :twitter
            end
            it { should redirect_to(edit_user_registration_path) }
            it { should set_the_flash[:alert].to('Could not authenticate you from Twitter because "Someone has already linked to this account".') }
          end
          it 'should not create a new Account' do
            expect {
              get :twitter
            }.to_not change(Account, :count)
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
            it { should set_the_flash[:notice].to('Successfully authenticated from Developer account.') }
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
            it { should set_the_flash[:notice].to('Successfully authenticated from Developer account.') }
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

