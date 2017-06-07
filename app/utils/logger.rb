require 'colorize'

class Logger

  def self.enable_debug
    @debug = true
    debug('Debug logging enabled')
  end

  # Ensure passing string type into 'puts' by wrapping 'msg' into a string

  def self.debug(msg)
    puts("#{msg}".green) if @debug
  end

  def self.warn(msg)
    puts("#{msg}".light_white.on_red)
  end

  def self.info(msg)
    puts("#{msg}".yellow)
  end

  def self.error(msg)
    puts("#{msg}".red)
  end
end
