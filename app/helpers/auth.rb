require_relative('../utils/db_util')

class Auth
  def self.get_user
    return ENV['USER']
  end
end
