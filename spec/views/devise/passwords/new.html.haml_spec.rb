require 'spec_helper'

describe 'devise/passwords/new.html.haml' do

  context 'with a new user resource' do
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
    end

    describe 'the new password reset request form' do
      it 'renders the form' do
        render

        assert_select 'form[action=?][method=?]', user_password_path, 'post' do
          assert_select 'input#user_email[name=?]', 'user[email]'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'user_email', 'Email'
      end
      it 'renders all form placeholders' do
        render

        assert_select '#user_email[placeholder=?]',
                      t('simple_form.placeholders.defaults.email')
      end
    end
  end

end
