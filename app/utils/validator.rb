require 'colorize'
require_relative 'log'

module Validator

  module_function

  # Check if the argument is nil or empty.
  def test(args)
    invalid = args.nil?

    unless invalid
      # args is an array
      if args.is_a? Array
        invalid = args.empty?

        unless invalid
          args.each do |arg|
            invalid = false if arg.nil? or arg == ''
          end
        end
      # args is a string
      elsif args.is_a? String
        invalid = (args == '')
      end
    end

    Log.error('Argument must not be nil or empty!') if invalid

    return !invalid
  end
end
