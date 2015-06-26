require 'rails_helper'

describe 'users/versions/index.html.haml', type: :view do
  context 'with a logged in user' do
    let(:user) { create :user }
    let(:ability) { Object.new.tap { |o| o.extend(CanCan::Ability) } }
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:current_ability).and_return(@ability)
    end

    context 'with a array of versions' do
      let(:versions) { [version] }
      before(:each) { assign(:versions, versions) }

      context 'with a PaperTrail Version with a ip' do
        let(:ip) { Faker::Internet.ip_v4_address }
        let(:version) { create :papertrail_version, ip: ip, whodunnit: user.id.to_s }

        it 'renders the IP address as a geocoded element' do
          render
          assert_select ".list-group-item-text .ip-address [data-geocode-ip='#{ip}']", text: ip
        end
      end

      context 'with a PaperTrail Version with a user_agent' do
        let(:version) do
          create :papertrail_version,
                 user_agent: user_agent,
                 whodunnit: user.id.to_s
        end
        let(:user_agent) { nil }

        context 'with a Android Webkit User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Android 4.0 (Android 4.0.3)'
            assert_select '.list-group-item-text .user-agent .fa-android'
          end
        end

        context 'with a BlackBerry 7.1 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'BlackBerry 7.1.0.346 (BlackBerry 9900)'
            assert_select '.list-group-item-text .user-agent .fa-mobile'
          end
        end

        context 'with a iPad iOS 6.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Safari 6.0 (iOS 6.0)'
            assert_select '.list-group-item-text .user-agent .fa-apple'
          end
        end

        context 'with a iPhone iOS 4.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (iPhone; U; ru; CPU iPhone OS 4_2_1 like Mac OS X; ru) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148a Safari/6533.18.5' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Safari 5.0.2 (iOS 4.2.1)'
            assert_select '.list-group-item-text .user-agent .fa-apple'
          end
        end

        context 'with an iPhone iOS 8.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/8.0 Mobile/11A465 Safari/9537.53' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Safari 8.0 (iOS 8.0)'
            assert_select '.list-group-item-text .user-agent .fa-apple'
          end
        end

        context 'with an iPod Touch iOS 7.0.6 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (iPod touch; CPU iPhone OS 7_0_6 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B651 Safari/9537.53' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Safari 7.0 (iOS 7.0.6)'
            assert_select '.list-group-item-text .user-agent .fa-apple'
          end
        end

        context 'with a Chrome OS 30 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (X11; CrOS armv7l 4537.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.38 Safari/537.36' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Chrome 30.0.1599.38 (ChromeOS 4537.56.0)'
            assert_select '.list-group-item-text .user-agent .fa-desktop'
          end
        end

        context 'with a Debian Iceweasel 8.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (X11; Linux Debian i686; rv:8.0) Gecko/20100101 Firefox/8.0 Iceweasel/8.0' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Firefox 8.0 (Linux Debian i686)'
            assert_select '.list-group-item-text .user-agent .fa-linux'
          end
        end

        context 'with an Linux Iceweasel 17.0.1 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20121202 Firefox/17.0 Iceweasel/17.0.1' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Firefox 17.0 (Linux x86_64)'
            assert_select '.list-group-item-text .user-agent .fa-linux'
          end
        end

        context 'with a OS X Chrome 41 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Chrome 41.0.2227.1 (OS X 10.10.1)'
            assert_select '.list-group-item-text .user-agent .fa-laptop'
          end
        end

        context 'with a OS X Safari 7.0.3 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Safari 7.0.3 (OS X 10.9.3)'
            assert_select '.list-group-item-text .user-agent .fa-laptop'
          end
        end

        context 'with a Windows Firefox 36.0 User agent String' do
          let(:user_agent) { 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Firefox 36.0 (Windows 8.1)'
            assert_select '.list-group-item-text .user-agent .fa-windows'
          end
        end

        context 'with a Windows Internet Explorer 8.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Internet Explorer 8.0 (Windows XP)'
            assert_select '.list-group-item-text .user-agent .fa-windows'
          end
        end

        context 'with a Windows Internet Explorer 11.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Internet Explorer 11.0 (Windows 7)'
            assert_select '.list-group-item-text .user-agent .fa-windows'
          end
        end

        context 'with a Windows IE Mobile 9.0 User Agent String' do
          let(:user_agent) { 'Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)' }

          it 'should render the parsed user agent' do
            render
            assert_select '.list-group-item-text .user-agent', text: 'Internet Explorer 9.0 (Windows Phone OS 7.5)'
            assert_select '.list-group-item-text .user-agent .fa-windows'
          end
        end
      end
    end
  end
end
