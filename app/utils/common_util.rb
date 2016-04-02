require 'colorize'

class CommonUtil
  @@debug = false

  def self.enable_debug
    @@debug = true
    puts('Debug logging enabled')
  end

  def self.log_debug(msg)
    puts(msg) if @@debug
  end

  def self.log_important(msg)
    puts(msg.red)
  end
end