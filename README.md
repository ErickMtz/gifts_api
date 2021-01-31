# gifts_api_test

This is a skeleton of a rails app to serve as a starting point for the code challenge you are about to solve.

Rails and Ruby versions: Defined on the Gemfile

##Configuration

The app has the following tools preinstalled and configured:
  - Rspec
  - Factorybot
  - Faker
  - Database Cleaner
  - Shoulda Matchers

#Getting Started

After cloning the repo:

### Start the server

```
docker-compose -f docker-compose.dev.yml up -d
```
This starts both database and web applications

You should add --build option first time
```
docker-compose -f docker-compose.dev.yml up -d --build
```

### Run tests

```
docker exec -it gifts_api_development_web bash
bundle exec rake db:create
bundle exec rspec
```

### Docs
Docs are in `localhost\api-docs` once server is running

### Create a user
```
docker exec -it gifts_api_development_web bash
rails console
User.create(email: 'admin@email.com', password: '123456', password_confirmation: '123456')
```

### Create Application

```
docker exec -it gifts_api_development_web bash
rails console
Doorkeeper::Application.create(name: 'AdminApptegy', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: ["read"])
```
