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

        opts.on('-f', '--find [label]', 'find account') do |label|
          result = DbUtil.find(label)
          result.each do |row|
            puts(row)
          end
        end

        opts.on('-a', '--add [label],[username],[password]', Array, 'add new account') do |acct_info|
          puts(acct_info)
          DbUtil.add_new(acct_info[0], acct_info[1], acct_info[2])
        end
      end.parse!

      p ARGV
    rescue Exception => e
      puts(e)
    end
  end
end

Main.run

