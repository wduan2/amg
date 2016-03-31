#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/common_util'
require_relative 'utils/db_util'

class AcctMg
  def self.print_result(result)
    ap result if result.length > 0
  end

  def self.run
    begin
      OptionParser.new do |opts|
        # TODO: Make '--debug' always execute first
        opts.on_tail('--debug', 'enable debug mode') do
          CommonUtil.enable_debug
        end

        opts.on('-l', '--list', 'list all accounts') do
          print_result(DbUtil.list_all)
        end

        opts.on('-f', '--find [label]', 'find account') do |label|
          print_result(DbUtil.find_acct(label))
        end

        # Multiple arguments can not be separated by space
        opts.on('-a', '--add [label,username,password]', Array, 'add new account') do |acct_info|
          DbUtil.add_new(acct_info[0], acct_info[1], acct_info[2])
        end

        opts.on('-d', '--delete [label]', 'delete accounts') do |label|
          DbUtil.delete(label)
        end
      end.parse!
    rescue Exception => e
      puts("Error: #{e}")
    end
  end
end

AcctMg.run
