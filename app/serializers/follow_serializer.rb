class FollowSerializer < ActiveModel::Serializer
  type :follow

  attributes :id, :follower_id, :following_id, :created_at, :updated_at
end
