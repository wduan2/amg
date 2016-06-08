require 'colorize'

class Logger
  @@debug = false

  def self.enable_debug
    @@debug = true
    self.debug('Debug logging enabled')
  end

  def self.debug(msg)
    puts(msg) if @@debug
  end

  def self.info(msg)
    puts(msg.green)
  end

  def self.error(msg)
    puts(msg.red)
  end
end
