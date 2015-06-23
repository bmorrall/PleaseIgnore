require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe OrganisationsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Organisation. As you add validations to Organisation, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:organisation).reject { |attribute| %w(permalink).include? attribute }
  end

  let(:invalid_attributes) do
    { name: '' }
  end

  describe 'GET #show' do
    context 'as a signed in user' do
      login_user

      context 'with read Organisation ability' do
        grant_ability :read, Organisation

        it 'assigns the requested organisation as @organisation' do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :show, id: organisation.to_param
          expect(assigns(:organisation)).to eq(organisation)
        end

        it "renders the 'show' template" do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :show, id: organisation.to_param
          expect(response).to render_template('show')
          expect(response).to render_with_layout('dashboard')
        end
      end

      it 'should raise a CanCan::AccessDenied without access' do
        organisation = create(:organisation)
        logged_in_user.add_role :owner, organisation

        expect do
          get :show, id: organisation.to_param
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'GET #edit' do
    context 'as a signed in user' do
      login_user

      context 'with update Organisation ability' do
        grant_ability :update, Organisation

        it 'assigns the requested organisation as @organisation' do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :edit, id: organisation.to_param
          expect(assigns(:organisation)).to eq(organisation)
        end

        it "renders the 'edit' template" do
          organisation = create(:organisation)
          logged_in_user.add_role :owner, organisation

          get :edit, id: organisation.to_param
          expect(response).to render_template('edit')
          expect(response).to render_with_layout('dashboard_backend')
        end
      end

      it 'should raise a CanCan::AccessDenied without access' do
        organisation = create(:organisation)
        logged_in_user.add_role :owner, organisation

        expect do
          get :edit, id: organisation.to_param
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'PUT #update' do
    context 'as a signed in user' do
      login_user

      context 'with update Organisation ability' do
        grant_ability :update, Organisation

        context 'with valid params' do
          let(:new_attributes) do
            attributes_for(:organisation).reject { |key, _value| %w(permalink).include? key }
          end

          it 'updates the requested organisation' do
            organisation = create(:organisation)
            logged_in_user.add_role :owner, organisation

            put :update, id: organisation.to_param, organisation: new_attributes
            organisation.reload
            expect(organisation.name).to eq new_attributes[:name]
          end

          it 'assigns the requested organisation as @organisation' do
            organisation = create(:organisation)
            logged_in_user.add_role :owner, organisation

            put :update, id: organisation.to_param, organisation: new_attributes
            expect(assigns(:organisation)).to eq(organisation)
          end

          it 'redirects to the organisation' do
            organisation = create(:organisation)
            logged_in_user.add_role :owner, organisation

            put :update, id: organisation.to_param, organisation: new_attributes
            expect(response).to redirect_to(organisation)
            is_expected.to set_flash[:notice].to(
              t('flash.actions.update.notice', resource_name: 'Organisation')
            )
          end
        end

        context 'with invalid params' do
          it 'assigns the organisation as @organisation' do
            organisation = create(:organisation)
            logged_in_user.add_role :owner, organisation

            put :update, id: organisation.to_param, organisation: invalid_attributes
            expect(assigns(:organisation)).to eq(organisation)
            expect(assigns(:organisation).errors).to_not be_empty
          end

          it "re-renders the 'edit' template" do
            organisation = create(:organisation)
            logged_in_user.add_role :owner, organisation

            put :update, id: organisation.to_param, organisation: invalid_attributes
            expect(response).to render_template('edit')
            expect(response).to render_with_layout('dashboard_backend')
          end
        end
      end

      it 'should raise a CanCan::AccessDenied without access' do
        organisation = create(:organisation)
        logged_in_user.add_role :owner, organisation

        expect do
          put :update, id: organisation.to_param, organisation: invalid_attributes
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
