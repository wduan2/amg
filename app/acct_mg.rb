#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/db_util'

class AcctMg
  def self.print_result(result)
    if result.length > 0
      ap result
    else
      puts 'No account found in database.'
    end
  end

  def self.run
    begin
      OptionParser.new do |opts|
        opts.on('-l', '--list', 'list all accounts') do
          result = DbUtil.list_all.collect { |row| row }
          print_result(result)
        end

        opts.on('-f', '--find [label]', 'find account') do |label|
          result = DbUtil.find_acct(label).collect { |row| row }
          print_result(result)
        end

        opts.on('-a', '--add [label],[username],[password]', Array, 'add new account') do |acct_info|
          DbUtil.add_new(acct_info[0], acct_info[1], acct_info[2])
        end
      end.parse!

      p ARGV
    rescue Exception => e
      puts("Exception happened: #{e}")
    end
  end
end

AcctMg.run
