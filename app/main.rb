#!/usr/bin/ruby

require 'optparse'
require_relative 'utils/db_util'

class Main
  def self.run
    begin
      OptionParser.new do |opts|
        opts.on('-l', '--list', 'list all') do
          result = DbUtil.list_all
          result.each do |row|
            puts(row)
          end
        end
      end.parse!

      p ARGV
    rescue Exception => e
      puts(e)
    end
  end
end

Main.run

