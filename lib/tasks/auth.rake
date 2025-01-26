namespace :auth do
  desc "[FOR TESTING PURPOSE] Generate JWT for a user with the given user_id"
  task :generate_token, [:user_id] => :environment do |_t, args|
    require 'jwt'

    user_id = args[:user_id]
    if user_id.nil?
      puts "Usage: rake auth:generate_token[<user_id>]"
      exit 1
    end

    user = User.find_by(id: user_id)
    if user.nil?
      puts "User with ID=#{user_id} not found"
      exit 1
    end

    payload = {
      user_id: user.id,
      name: user.name,
      iat: Time.current.to_i,
    }

    token = JsonWebToken.encode(payload, (Time.current + 1.hours).to_i)
    puts "Generated JWT for user #{user.id}:"
    puts token
  end
end
