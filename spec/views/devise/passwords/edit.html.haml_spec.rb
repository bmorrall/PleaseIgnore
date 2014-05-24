require 'spec_helper'

describe 'devise/passwords/edit.html.haml' do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
      user.reset_password_token = 'token12345678'
    end

    it 'renders the change password form' do
      render

      assert_select 'form[action=?][method=?]', user_password_path, 'post' do
        assert_select 'input#user_password[name=?]', 'user[password]'
        assert_select 'input#user_password_confirmation[name=?]', 'user[password_confirmation]'
        assert_select 'input#user_reset_password_token[type=hidden][name=?][value=?]',
                      'user[reset_password_token]',
                      'token12345678'
      end
    end
  end

end
