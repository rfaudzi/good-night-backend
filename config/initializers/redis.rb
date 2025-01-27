require 'redis'

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']

REDIS = Redis.new(
  host: REDIS_HOST,
  port: REDIS_PORT
)
