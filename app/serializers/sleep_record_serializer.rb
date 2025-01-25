class SleepRecordSerializer < ActiveModel::Serializer
  type :sleep_record

  attributes :id, :user_id, :start_time, :end_time, :duration, :created_at, :updated_at
end
