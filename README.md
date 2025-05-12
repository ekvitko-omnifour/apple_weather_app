# Apple Weather App

A super-lightweight Ruby on Rails application that takes a user-entered address, fetches current and extended forecast data from the OpenWeather API, and displays the result in a clean fashion.

No database is used — all data is fetched and cached in memory.

---

## Features

- Accepts full and partial address inputs (e.g., "1745 East Hallandale Beach Blvd. Hallandale Beach, FL 33009" or "Hallandale Beach, FL 33009")
- Leverages Geocoder to resolve coordinates of addresses
- Calls OpenWeather API for weather data
- Caches responses for 30 minutes per zip code (in-memory)
- Tailwind CSS styling
- Tested controllers, models, and service objects
- Cool Favicon (check it out ;))

## Requirements

- Ruby 3.4.3
- Rails 8
- Redis (optional but I would recommend if you want this app in prod)
- OpenWeather API Key (free)

## Setup

Once you have your API key, add it to your .env file. If you don't have a .env file, then run the following at the root of the app in your terminal:

```bash
touch .env
echo 'OPENWEATHER_API_KEY=your_api_key_here' >> .env
```

Then you can proceed to spin up the app:

```bash
bundle install
rails tailwindcss:build
rails s
```

## Decomposition of Objects

I tried my best to follow a clean object-oriented design (hopefully Sandi Metz would be proud). I split the responsibilities into
focused and testable components:

| Component                        | Responsibility                                                                 |
|----------------------------------|--------------------------------------------------------------------------------|
| `Address` (PORO)                 | Parses and geocodes raw address input, caches results, exposes metadata        |
| `OpenweatherLookupService`       | Fetches data from OpenWeather’s API, handles caching and response parsing      |
| `Forecast` (PORO)                | Represents structured weather data for display, including extended forecasts   |
| `ForecastsController`            | Orchestrates input, delegates to service objects, and renders views            |

This decomposition ensures:
- Minimal logic in controllers
- Reusable, isolated business logic  
- Clear boundaries between input, processing, and presentation  
- Ease of testing and future extensibility

## Thoughts

Ultimately there are a lot of improvements that can be made however, this is a great solid foundation for a lightweight, production-friendly
web app that has very few responsibilities. If we wanted to extend it's functionality, it would be pretty easy given the components I've
broken the app into.

I chose not to go with a database for this project only because there are no requirements to persist any data, but as the application
requirements grow, I would imagine we would need to introduce some database to keep track of historical data and analytics. We can always
introduce ActiveRecord, pair that with PostgreSQL and we've got ourselves a match made in heaven.

Oh yeah! Redis - I definitely would use Redis in production. I demonstrated a very simple caching protocol in this app which works great for
what this app does but if we were to deploy it, functionally nothing would really need to change in the logic. We would just need to change the
cache config to redis and ensure we are pointing to our redis instance.

I wanted to add system specs but decided against it as I felt it may be overkill for a single input with minimal functionality.
