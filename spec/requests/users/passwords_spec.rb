require 'rails_helper'

describe 'Passwords', type: :request do
  describe 'GET new' do
    context 'as a visitor' do
      it 'renders the new page' do
        get new_user_password_path
        expect(response.status).to be(200)
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get new_user_password_path
        assert_select 'body.users-passwords.users-passwords-new'
      end
      it 'includes the page title' do
        get new_user_password_path
        assert_select 'title', "#{application_name} | #{t 'devise.passwords.new.page_title'}"
      end
    end
  end
end
