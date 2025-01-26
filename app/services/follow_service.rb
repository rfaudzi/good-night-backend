module FollowService
  module_function

  def create(*args); FollowService::Create.new(*args).call; end
  def delete(*args); FollowService::Delete.new(*args).call; end
end
