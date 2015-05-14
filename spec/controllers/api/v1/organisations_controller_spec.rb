require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController, type: :controller do
  describe 'GET #index' do
    context 'as a signed in user' do
      login_user

      context 'with read Organisation ability' do
        grant_ability :read, Organisation

        it 'assigns the requested organisations to @organisations' do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :index, id: organisation.to_param, format: :json
          expect(assigns(:organisations)).to eq([organisation])
        end

        it "renders the 'index' template" do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :index, id: organisation.to_param, format: :json
          expect(response).to render_template('index')
        end
      end

      it 'should raise a CanCan::AccessDenied without access' do
        organisation = create(:organisation)
        logged_in_user.add_role :owner, organisation

        expect do
          get :index, id: organisation.to_param, format: :json
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'GET #show' do
    context 'as a signed in user' do
      login_user

      context 'with read Organisation ability' do
        grant_ability :read, Organisation

        it 'assigns the requested organisation as @organisation' do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :show, id: organisation.to_param, format: :json
          expect(assigns(:organisation)).to eq(organisation)
        end

        it "renders the 'show' template" do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :show, id: organisation.to_param, format: :json
          expect(response).to render_template('show')
        end
      end

      it 'should raise a CanCan::AccessDenied without access' do
        organisation = create(:organisation)
        logged_in_user.add_role :owner, organisation

        expect do
          get :show, id: organisation.to_param, format: :json
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
