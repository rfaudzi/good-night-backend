module UserService
  module_function

  def list_sleep_record_following(*args); UserService::ListSleepRecordFollowing.new(*args).call; end
end
