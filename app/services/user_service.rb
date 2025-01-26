module UserService
  module_function

  def list_sleep_records_following(*args); UserService::ListSleepRecordsFollowing.new(*args).call; end
end
