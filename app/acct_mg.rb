#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/common_util'
require_relative 'utils/db_util'

class AcctMg
  def self.print_result(result)
    if result.length > 0
      ap result
      CommonUtil.log_important("Total return accounts: #{result.length}")
    end
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

        opts.on('-u', '--username [label,new_username]', Array, 'update the username') do |update|
          DbUtil.update_username(update[0], update[1])
        end

        opts.on('-p', '--password [label,new_password]', Array, 'update the password') do |update|
          DbUtil.update_password(update[0], update[1])
        end

        opts.on('-r', '--relable [label,new_label]', Array, 'relabel the account') do |update|
          DbUtil.relabel(update[0], update[1])
        end
      end.parse!
    rescue Exception => e
      puts("Error: #{e}")
    end
  end
end

AcctMg.run
