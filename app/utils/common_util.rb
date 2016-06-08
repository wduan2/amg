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

  def self.log_info(msg)
    puts(msg.red)
  end

  # Check if the argument is nil or emtpy.
  def self.validate_arg(args)
    invalid = args.nil?
    
    unless invalid
      # args is an array
      if args.kind_of? Array
        invalid = args.empty?

        unless invalid
          args.each do |arg|
            if arg.nil? or arg == ''
              invalid = false
            end
          end
        end
      # args is a string  
      elsif args.kind_of? String
        invalid = (args == '')        
      end  
    end

    if invalid
      puts('Arguement must not be nil or emtpy'.red)
    end

    return !invalid
  end
end
