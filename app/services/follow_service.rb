module FollowService
  module_function

  def create(*args); FollowService::Create.new(*args).call; end
end
