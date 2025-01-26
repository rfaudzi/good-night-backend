## Description
The "Good Night" application is designed to help users monitor their sleep patterns by tracking the times they go to bed and wake up.

## Prerequisites

* Ruby 3.2.2
* Rails 7.0.6
* PostgreSQL 16.1
* Docker 24.0.1
* Docker Compose 2.19.1

## How to run the application
* Install RVM
```
curl -L get.rvm.io | bash -s stable
source ~/.bash_profile
```
* Install Ruby 3.2.2
```
rvm install ruby-3.2.2
```
* clone this repository
```
git clone https://github.com/rfaudzi/good-night-backend.git
cd goodnight-backend
```
* Create gemset
```
rvm use 3.2.2@goodnight-backend --create
```
* Setup Bundler
```
gem install bundler
bundle install
```
* Setup environment variables
```
cp env.sample .env
```
* Setup database
```
docker compose up -d
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
```
* Run the application
```
puma -C config/puma.rb
```
* generate Auth token

`bundle exec rake auth:generate_token[<user_id>]`
example:
```
bundle exec rake auth:generate_token[1]
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.z5YQ92X4PJHtCMVDMwRqKT447ewJ9Wv8y1JkZbDx49Y
```
copy the token and use it in the header of the request

example curl command:
```
curl -X GET http://localhost:3000/api/v1/sleep_records -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.z5YQ92X4PJHtCMVDMwRqKT447ewJ9Wv8y1JkZbDx49Y"
```

## API Documentation
swagger is available at `http://localhost:3000/api-docs`

