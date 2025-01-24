FactoryBot.define do
  factory :sleep_record do
    user
    start_time { 1.hour.ago }
    end_time { Time.current }
    duration { 8.hours }
  end
end
