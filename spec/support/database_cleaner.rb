RSpec.configure do |config|
  DatabaseCleaner.strategy = :truncation

  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
