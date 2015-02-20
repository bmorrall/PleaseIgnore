require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  include OmniauthHelpers
  before(:each) { @request.env['devise.mapping'] = Devise.mappings[:user] }

  [
    :facebook,
    :twitter,
    :github,
    :google_oauth2
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
          grant_ability :create, Account

          context 'with no existing account' do
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { is_expected.to redirect_to(new_user_registration_path) }
              it do
                is_expected.to set_flash[:notice].to(
                  t('devise.omniauth_callbacks.success_registered', kind: provider_name)
                )
              end
              it "should set #{session_key} session data" do
                expect(session[session_key]).not_to be_empty
              end
            end
            it 'should not create a new Account' do
              expect do
                get provider
              end.to_not change(Account, :count)
            end
          end
          context 'with a previously linked account' do
            let(:existing_user) { create(:user) }
            before(:each) do
              create(:"#{provider}_account", uid: auth_hash.uid, user: existing_user)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { is_expected.to redirect_to(edit_user_registration_path) }
              it do
                is_expected.to set_flash[:notice].to(
                  t('devise.omniauth_callbacks.success_authenticated', kind: provider_name)
                )
              end
              it "should not set #{session_key} session data" do
                expect(session[session_key]).to be_nil
              end
            end
            it 'should not create a new Account' do
              expect do
                get provider
              end.to_not change(Account, :count)
            end
          end
          context 'with a disabled account' do
            before(:each) do
              account = build_stubbed(:"#{provider}_account")
              allow(account).to receive(:enabled?).and_return(false)
              allow(Account).to receive(:find_for_oauth).and_return(account)
            end
            context 'with a valid request' do
              before(:each) { get provider }
              it { is_expected.to redirect_to(new_user_session_path) }
              it do
                is_expected.to set_flash[:alert].to(
                  t('devise.omniauth_callbacks.failure',
                    kind: provider_name,
                    reason: t('account.reasons.failure.account_disabled')
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

          context 'with no existing account' do
            context 'with a valid request' do
              before(:each) { get provider }
              it { is_expected.to redirect_to(edit_user_registration_path) }
              it do
                is_expected.to set_flash[:notice].to(
                  t('devise.omniauth_callbacks.success_linked', kind: provider_name)
                )
              end
            end
            it 'should create a Account belonging to the user' do
              expect do
                get provider
              end.to change(Account, :count).by(1)
              expect(Account.last.user).to eq(user)
            end
            context 'with an invalid account' do
              before(:each) do
                expect_any_instance_of(Account).to receive(:save).and_return(false)
              end

              context 'with a valid request' do
                before(:each) { get provider }
                it { is_expected.to redirect_to(edit_user_registration_path) }
                it do
                  is_expected.to set_flash[:alert].to(
                    t('devise.omniauth_callbacks.failure',
                      kind: provider_name,
                      reason: t('account.reasons.failure.account_invalid')
                    )
                  )
                end
              end
              it 'should not create a new Account' do
                expect do
                  get provider
                end.to_not change(Account, :count)
              end
            end
          end
          context 'with the account linked to the user' do
            before(:each) do
              create(:"#{provider}_account", uid: auth_hash.uid, user: user)
            end
            it 'should not create a new Account' do
              expect do
                get provider
              end.to_not change(Account, :count)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { is_expected.to redirect_to(edit_user_registration_path) }
              it do
                is_expected.to set_flash[:notice].to(
                  t('devise.omniauth_callbacks.success_linked', kind: provider_name)
                )
              end
            end
          end
          context "with another #{provider} account linked to the user" do
            before(:each) do
              create(:"#{provider}_account", user: user)
            end
            it 'should not create a new Account' do
              expect do
                get provider
              end.to_not change(Account, :count)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { is_expected.to redirect_to(edit_user_registration_path) }
              it do
                is_expected.to set_flash[:alert].to(
                  t('devise.omniauth_callbacks.failure',
                    kind: provider_name,
                    reason: t('account.reasons.failure.account_limit', kind: provider_name)
                  )
                )
              end
            end
          end
          context 'with a account linked to another user' do
            before(:each) do
              create(:"#{provider}_account", uid: auth_hash.uid)
            end
            context 'with a valid request' do
              before(:each) do
                get provider
              end
              it { is_expected.to redirect_to(edit_user_registration_path) }
              it do
                is_expected.to set_flash[:alert].to(
                  t('devise.omniauth_callbacks.failure',
                    kind: provider_name,
                    reason: t('account.reasons.failure.previously_linked')
                  )
                )
              end
            end
            it 'should not create a new Account' do
              expect do
                get provider
              end.to_not change(Account, :count)
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
        grant_ability :create, Account

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { is_expected.to redirect_to(new_user_registration_path) }
            it do
              is_expected.to set_flash[:notice].to(
                t('devise.omniauth_callbacks.success_registered', kind: 'Developer')
              )
            end
            it 'should set devise.developer_data session data' do
              expect(session['devise.developer_data']).not_to be_empty
            end
          end
          it 'should not create a new Account' do
            expect do
              get :developer
            end.to_not change(Account, :count)
          end
        end
        context 'with a previously linked account' do
          let(:existing_user) { create(:user) }
          before(:each) do
            create(:developer_account, uid: auth_hash.uid, user: existing_user)
          end
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { is_expected.to redirect_to(new_user_session_path) }
            it do
              is_expected.to set_flash[:alert].to(
                t('devise.omniauth_callbacks.failure',
                  kind: 'Developer',
                  reason: t('account.reasons.failure.account_disabled')
                )
              )
            end
            it 'should not set devise.developer_data session data' do
              expect(session['devise.developer_data']).to be_nil
            end
          end
          it 'should not create a new Account' do
            expect do
              get :developer
            end.to_not change(Account, :count)
          end
        end
      end
      context 'as a user' do
        let(:user) { create(:user) }
        before(:each) { sign_in user }
        grant_ability :create, Account

        context 'with no existing account' do
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { is_expected.to redirect_to(edit_user_registration_path) }
            it do
              is_expected.to set_flash[:notice].to(
                t('devise.omniauth_callbacks.success_linked', kind: 'Developer')
              )
            end
          end
          it 'should create a Account belonging to the user' do
            expect do
              get :developer
            end.to change(Account, :count).by(1)
            expect(Account.last.user).to eq(user)
          end
        end
        context 'with a previously linked account' do
          before(:each) do
            create(:developer_account, uid: auth_hash.uid, user: user)
          end
          it 'should not create a new Account' do
            expect do
              get :developer
            end.to_not change(Account, :count)
          end
        end
        context 'with a account linked to another user' do
          before(:each) do
            create(:developer_account, uid: auth_hash.uid)
          end
          context 'with a valid request' do
            before(:each) do
              get :developer
            end
            it { is_expected.to redirect_to(edit_user_registration_path) }
            it do
              is_expected.to set_flash[:alert].to(
                t('devise.omniauth_callbacks.failure',
                  kind: 'Developer',
                  reason: t('account.reasons.failure.previously_linked')
                )
              )
            end
          end
          it 'should not create a new Account' do
            expect do
              get :developer
            end.to_not change(Account, :count)
          end
        end
      end
    end
  end

end
