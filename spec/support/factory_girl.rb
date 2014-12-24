# www.rubydoc.info/gems/factory_girl/file/GETTING_STARTED.md
RSpec.configure do |config|
  # Use FactoryGirl syntax methods (create, build, build_stubbed)
  config.include FactoryGirl::Syntax::Methods

  # Ensure Factories are valid before starting suite
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
