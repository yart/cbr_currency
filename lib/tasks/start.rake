namespace :cbr_currency do
  desc 'Start Sidekiq if not running and then start Rails server'
  task :run do
    if system('pgrep -f "sidekiq"')
      puts 'Sidekiq is already running.'
    else
      puts 'Sidekiq is not running. Starting Sidekiq...'
      system('bundle exec sidekiq -C config/sidekiq.yml &')
      sleep 5
    end

    system('bundle exec rails server -d')
  end

  desc 'Stop Sidekiq and Rails server'
  task :stop do
    puts 'Stopping Sidekiq...'
    system('pkill -f "sidekiq"')

    puts 'Stopping Rails server...'
    system('pkill -f "rails"')
  end

  namespace :db do
    desc 'Setup the database'
    task setup: %i[create migrate seed]

    desc 'Reset the database'
    task reset: %i[drop create migrate seed]

    desc 'Create the database'
    task create: :environment do
      Rake::Task['db:create'].invoke
    end

    desc 'Drop the database'
    task drop: :environment do
      Rake::Task['db:drop'].invoke
    end

    desc 'Migrate the database'
    task migrate: :environment do
      Rake::Task['db:migrate'].invoke
    end

    desc 'Seed the database'
    task seed: :environment do
      Rake::Task['db:seed'].invoke
    end
  end
end
