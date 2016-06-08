require 'colorize'
require_relative 'logger'

class Validator
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
      Logger.info('Arguement must not be nil or emtpy')
    end

    return !invalid
  end
end
