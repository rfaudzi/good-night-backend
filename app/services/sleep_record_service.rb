module SleepRecordService
  module_function

  def track_sleep(*args); SleepRecordService::TrackSleep.new(*args).call; end
end
