class CommonUtil
  @@debug = false

  def self.enable_debug
    puts 'Debug logging enabled'
    @@debug = true
  end

  def self.log_debug(msg)
    puts msg if @@debug
  end
end