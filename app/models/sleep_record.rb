class SleepRecord < ApplicationRecord
  belongs_to :user
  
  validates :start_time, presence: true
  validate :end_time_after_start_time?

  def self.to_list_objects(list_data)
    list_data.map do |data|
      new(data)
    end
  end
  
  private
  
  def end_time_after_start_time?
    return if start_time.blank? || end_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time") 
    end
  end
end
