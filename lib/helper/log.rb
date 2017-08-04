module Log

  module_function

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def r(text); colorize(text, 31); end
  def g(text); colorize(text, 32); end
  def y(text); colorize(text, 33); end

  def enable_debug
    @debug = true
    debug('Debug logging enabled')
  end

  def log(msg)
    puts msg
  end

  def debug(msg)
    puts g(msg.to_s) if @debug
  end

  def warn(msg)
    puts r(msg.to_s)
  end

  def info(msg)
    puts y(msg.to_s)
  end

  def error(msg)
    puts r(msg.to_s)
  end
end
