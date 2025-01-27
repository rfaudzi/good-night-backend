class User < ApplicationRecord
  has_many :sleep_records
  
  validates :name, presence: true

  def self.find_by_id(id)
    cache_key = "user_data:#{id}"
    cached_user = REDIS.get(cache_key)
    if cached_user.present?
      data_user = JSON.parse(cached_user).with_indifferent_access
      return new(data_user)
    else
      user = User.find_by(id: id)
      REDIS.set(cache_key, user.to_json, ex: 5.minutes) if user.present?
      user
    end
  end
end
