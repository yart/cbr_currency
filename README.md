# Currency Rates Application

This is a web application that fetches and displays currency exchange rates from the Central Bank of Russia (CBR).

![CBR USD&EUR Rates](images/cbr_usd_eur_rates.png)

## Backend

### Technologies Used

- Operating System: Linux
- Database: PostgreSQL 12
- Ruby on Rails: 5.2.8.1
- Background Job Processing: Sidekiq

### Setup and Installation

- Ensure you have a Linux-based operating system.
- Install PostgreSQL 12.
- Install Ruby on Rails 5.2.8.1.
- Configure the database.yml file with the appropriate database settings.
- Run bundle install to install project dependencies.
- Run the following commands to set up the database and seed it with the latest currency exchange rates for the past month:

```bash
rails db:create
rails db:migrate
rails db:seed
```

Also, you can run

```bash
rails cbr_currency:setup
```

to run these all using one command.

### Daily Update Task

The application automatically fetches currency exchange rates (USD and EUR) from the CBR API every hour using Sidekiq. This task updates the database with the latest rates.

### Seeding

The seeds.rb file includes a task that prepares the database upon project setup and collects currency rates for the past month.

### Testing

RSpec is used for testing, covering various aspects of the application.

## Frontend

### Technologies Used

- HTML5
- CSS3
- JavaScript ES6
- Chart Library: C3.js

### Currency Rates Chart

The homepage displays a chart using the C3.js library to visualize the currency exchange rates for the past month.

### Data Display

The application focuses on displaying the date, currency code (USD or EUR), and the exchange rate. Other details are not stored in the database.

## Usage

- Clone the repository.
- Set up the backend and frontend dependencies as described in the "Setup and Installation" section.
- Run the Rails server:

```bash
bundle exec sidekiq -C config/sidekiq.yml &
rails s -d
```

Or you can do the sam by one command:

```bash
rails cbr_currency:run
```

Visit http://localhost:3000 in your web browser to view the currency rates chart.

## Files added to the Rails scaffold or changed here

```
app/controllers/application_controller.rb
app/controllers/currency_rates_controller.rb
app/jobs/update_currency_rates_job.rb
app/models/currency_rate_updater.rb
app/services/currency_rate_updater.rb
app/views/currency_rates/index.html.erb
app/views/currency_rates/application.html.erb
config/initializeers/sidekiq.yml
config/application.rb
config/database.yml
config/routes.rb
config/schedule.yml
config/sidekiq.yml
db/migrate/*
db/schema.rb
db/seeds.rb
lib/tasks/start.rake
spec/**/*
Gemfile
README.md
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
