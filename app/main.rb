#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/db_util'

class Main
  def self.run
    begin
      OptionParser.new do |opts|
        opts.on('-l', '--list', 'list all') do
          result = DbUtil.list_all.collect { |row| row }
          ap result
        end

        opts.on('-f', '--find [label]', 'find account') do |label|
          result = DbUtil.find(label) { |row| row }
          ap result
        end

        opts.on('-a', '--add [label],[username],[password]', Array, 'add new account') do |acct_info|
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

