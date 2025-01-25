module SleepRecordService
  module_function

  def create(*args); SleepRecordService::Create.new(*args).call; end
  def update(*args); SleepRecordService::Update.new(*args).call; end
end
