module Auth

  module_function

  def get_user
    return ENV['USER']
  end
end
