module Seeds
  module Users
    def self.create
      puts 'Seeding users...'
      
      users_data = [
        { name: 'John Doe' },
        { name: 'Jane Smith' },
        { name: 'Bob Johnson' }
      ]

      users_data.each do |user_data|
        User.find_or_create_by!(name: user_data[:name])
      end
      
      puts 'Users seeded successfully!'
    end
  end
end 