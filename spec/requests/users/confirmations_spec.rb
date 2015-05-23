require 'rails_helper'

describe 'Confimations', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe 'GET show' do
    context 'as a logged in user' do
      login_user

      context 'with a valid confirmation token' do
        before(:each) { logged_in_user.send :generate_confirmation_token! }
        let!(:confirmation_token) { logged_in_user.instance_variable_get '@raw_confirmation_token' }

        it 'sets the user as confirmed' do
          now = Time.zone.now.midnight

          travel_to(now) do
            expect do
              get "/users/confirmation?confirmation_token=#{confirmation_token}"
              logged_in_user.reload
            end.to change(logged_in_user, :confirmed_at).to(now)
          end
        end

        it 'redirects back to the dashboard' do
          get "/users/confirmation?confirmation_token=#{confirmation_token}"
          expect(response).to redirect_to(dashboard_path)

          follow_redirect!
          assert_select '.alert.alert-success strong', t('devise.confirmations.confirmed')
        end
      end

      context 'with an invalid token' do
        it 'renders the new page with an invalid confirmation token message' do
          get '/users/confirmation'
          expect(response.status).to be(200)
          assert_select '.alert-danger strong', 'Unable to confirm your email address!'

          token_label = User.human_attribute_name(:confirmation_token)
          token_error = t('activerecord.errors.models.user.attributes.confirmation_token.blank')
          assert_select '.alert-danger li', "#{token_label} #{token_error}"
        end
      end
    end

    context 'as a visitor' do
      context 'with a valid confirmation token' do
        let(:user) { create :user }
        before(:each) { user.send :generate_confirmation_token! }
        let!(:confirmation_token) { user.instance_variable_get '@raw_confirmation_token' }

        it 'confirms the user and redirects to the login page' do
          now = Time.zone.now.midnight
          travel_to(now) do
            get "/users/confirmation?confirmation_token=#{confirmation_token}"
          end
          expect(response).to redirect_to(new_user_session_path)

          user.reload
          expect(user.confirmed_at).to eq now

          follow_redirect!
          assert_select '.alert.alert-success strong', t('devise.confirmations.confirmed')
        end
      end
    end
  end

  describe 'GET new' do
    context 'as a logged in user' do
      login_user

      it 'renders the new page' do
        get '/users/confirmation/new'
        expect(response.status).to be(200)
      end
    end

    context 'as a visitor' do
      it 'redirects to the sign in page' do
        get '/users/confirmation/new'
        expect(response).to redirect_to(new_user_session_path)

        follow_redirect!
        assert_select '.alert.alert-danger strong',
                      t('devise.failure.unauthenticated')
      end
    end
  end

  describe 'POST create' do
    context 'as a logged in user' do
      login_user

      it 'sets the confirmation_token on the user' do
        now = Time.zone.now.midnight

        travel_to(now) do
          expect do
            post '/users/confirmation', {}
            logged_in_user.reload
          end.to change(logged_in_user, :confirmation_token).from(nil)
        end

        expect(logged_in_user.confirmation_sent_at).to eq now
      end

      it 'sends an email with the confirmation link' do
        expect do
          post '/users/confirmation', {}
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        confirmation_email = ActionMailer::Base.deliveries.last
        expect(confirmation_email.to).to eq [logged_in_user.email]
        expect(confirmation_email.subject).to eq(
          "[PleaseIgnore TEST] #{t('devise.mailer.confirmation_instructions.subject')}"
        )
        expect(confirmation_email.body.decoded).to include(
          user_confirmation_url(confirmation_token: '')
        )
      end

      it 'redirects back to the dashboard' do
        post '/users/confirmation', {}
        expect(response).to redirect_to(dashboard_path)

        follow_redirect!
        assert_select '.alert.alert-success strong',
                      t('devise.confirmations.send_paranoid_instructions')
      end
    end
  end
end
