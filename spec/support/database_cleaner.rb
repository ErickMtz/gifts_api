DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: %w[ar_internal_metadata statuses]
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

