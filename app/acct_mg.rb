#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/logger'
require_relative 'utils/validator'
require_relative 'utils/db_util'

class AcctMg
  def self.print_result(result)
    if !result.nil? and result.length > 0
      ap result
      Logger.info("Total return accounts: #{result.length}")
    end
  end

  def self.run
    begin
      OptionParser.new do |opts|
        # TODO: Make '--debug' always execute first
        opts.on_tail('--debug', 'enable debug mode') do
          Logger.enable_debug
        end

        opts.on('-l', '--list', 'list all accounts') do
          print_result(DbUtil.list_all)
        end

        opts.on('-f', '--find [label]', 'find account') do |label|
          print_result(DbUtil.find_acct(label)) if Validator.validate_arg(label)
        end

        # Multiple arguments can not be separated by space
        opts.on('-a', '--add [label,username,password]', Array, 'add new account') do |acct_info|
          DbUtil.add_new(acct_info[0], acct_info[1], acct_info[2]) if Validator.validate_arg(acct_info)
        end

        opts.on('-q', '--question [label,question,answer]', Array, 'add new security question') do |qa_info|
          DbUtil.add_new_question(qa_info[0], qa_info[1], qa_info[2]) if Validator.validate_arg(qa_info)
        end

        opts.on('-d', '--delete [label]', 'delete accounts') do |label|
          DbUtil.delete(label) if Validator.validate_arg(label)
        end

        opts.on('-u', '--username [label,new_username]', Array, 'update the username') do |update|
          DbUtil.update_username(update[0], update[1]) if Validator.validate_arg(update)
        end

        opts.on('-p', '--password [label,new_password]', Array, 'update the password') do |update|
          DbUtil.update_password(update[0], update[1]) if Validator.validate_arg(update)
        end

        opts.on('-r', '--relable [label,new_label]', Array, 'relabel the account') do |update|
          DbUtil.relabel(update[0], update[1]) if Validator.validate_arg(update)
        end
      end.parse!
    rescue StandardError => e
      # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
      Logger.error("Error: #{e}")
    end
  end
end

AcctMg.run
