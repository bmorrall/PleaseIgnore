require 'spec_helper'

describe 'devise/passwords/edit.html.haml' do

  context 'with a new user resource' do
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
      user.reset_password_token = 'token12345678'
    end

    describe 'the change password form' do
      it 'renders the form' do
        render

        assert_select 'form[action=?][method=?]', user_password_path, 'post' do
          assert_select 'input#user_password[name=?]', 'user[password]'
          assert_select 'input#user_password_confirmation[name=?]', 'user[password_confirmation]'
          assert_select 'input#user_reset_password_token[type=hidden][name=?][value=?]',
                        'user[reset_password_token]',
                        'token12345678'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'user_password', 'New Password'
        assert_select 'label[for=?]',
                      'user_password_confirmation',
                      t('simple_form.labels.user.password_confirmation')
      end
      it 'renders all form placeholders' do
        render

        assert_select '#user_password[placeholder=?]', 'New Password'
        assert_select '#user_password_confirmation[placeholder=?]',
                      t('simple_form.placeholders.defaults.password_confirmation')
      end
    end
  end

end
