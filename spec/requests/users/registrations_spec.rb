require 'rails_helper'

describe 'Registrations', type: :request do
  describe 'GET new' do
    context 'as a visitor' do
      it 'renders the new page' do
        get new_user_registration_path
        expect(response.status).to be(200)
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get new_user_registration_path
        assert_select 'body.users-registrations.users-registrations-new'
      end
      it 'includes the page title' do
        get new_user_registration_path
        assert_select 'title', "#{application_name} | #{t 'devise.registrations.new.page_title'}"
      end
    end
  end

  describe 'POST create' do
    context 'as a visitor' do
      context 'with invalid account data', :omniauth do
        before(:each) do
          # Ensure the Account fails validation
          expect_any_instance_of(Account).to receive(:valid?).and_return(false)

          # Fake a successful oauth attempt
          auth_hash = create(:facebook_auth_hash)
          set_oauth :facebook, auth_hash
          post user_omniauth_authorize_path(:facebook)
          follow_redirect! # to callback path
          follow_redirect! # to user registration

          post user_registration_path,  user: attributes_for(:user)
        end

        it 'displays a failed login attempt to the user' do
          assert_select '.alert.alert-danger strong',
                        t('simple_form.error_notification.default_message')
          assert_select '.alert li', 'Unable to add your Facebook account'
        end
      end
    end
  end

  describe 'PUT update' do
    context 'as a user' do
      login_user

      context 'with valid user params' do
        let(:valid_user_params) { { name: Faker::Name.name } }

        it 'updates the logged in user' do
          put user_registration_path, user: valid_user_params

          logged_in_user.reload
          expect(logged_in_user.name).to eq valid_user_params[:name]
        end

        it 'creates a PaperTrail::Version for the user' do
          with_versioning do
            expect do
              put user_registration_path, user: valid_user_params
            end.to change(PaperTrail::Version, :count).by(1)
          end

          version = PaperTrail::Version.last
          expect(version.event).to eq 'update'
          expect(version.item).to eq logged_in_user
          expect(version.item_owner).to eq logged_in_user
          expect(version.whodunnit).to eq "#{logged_in_user.id} #{logged_in_user.email}"
        end
      end
    end
  end
end
