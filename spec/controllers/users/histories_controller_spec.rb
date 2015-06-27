require 'rails_helper'

RSpec.describe Users::HistoriesController, type: :controller do
  describe 'GET show' do
    context 'with a signed in User' do
      login_user
      grant_ability :read, PaperTrail::Version

      context 'with a PaperTrail::Version with the user id and email as the whodunnit' do
        let(:whodunnit) { "#{logged_in_user.id} #{logged_in_user.email}" }
        let!(:version) { create(:papertrail_version, whodunnit: whodunnit) }

        it 'should assign the version to @versions' do
          get :show
          expect(assigns(:versions)).to eq [version]
        end

        it 'should render the show template' do
          get :show
          expect(response).to be_success
          expect(response).to render_template(:show)
          expect(response).to render_with_layout(:dashboard_backend)
        end
      end

      context 'with a PaperTrail::Version with the user id as the whodunnit' do
        let!(:version) { create(:papertrail_version, whodunnit: logged_in_user.id.to_s) }

        it 'should assign the version to @versions' do
          get :show
          expect(assigns(:versions)).to eq [version]
        end

        it 'should render the show template' do
          get :show
          expect(response).to be_success
          expect(response).to render_template(:show)
          expect(response).to render_with_layout(:dashboard_backend)
        end
      end
    end
  end
end
