#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/logger'
require_relative 'utils/validator'
require_relative 'utils/db_util'

class AcctMg

  HELP_FLAG = '--help'
  DEBUG_FLAG = '--debug'

  def self.print_result(result)
    if !result.nil? and result.length > 0
      ap result
      Logger.info("Total return accounts: #{result.length}")
    end
  end

  def self.run
    begin
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: am [options]'

        # Boolean switch
        opts.on('--debug', '--[no-]debug', 'enable debug mode') do |flag|
          Logger.enable_debug if flag
        end

        opts.on('-h', '--help', 'help') do
          Logger.info(opts)
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

        opts.on('-r', '--relabel [label,new_label]', Array, 'relabel the account') do |update|
          DbUtil.relabel(update[0], update[1]) if Validator.validate_arg(update)
        end
      end

      # Doesn't work correctly for some special characters like '!' or '\' unless they are escaped
      # Make sure the --debug or --help always get executed at first
      if ARGV.delete(DEBUG_FLAG)
        ARGV.unshift(DEBUG_FLAG)
      end

      if ARGV.empty?
        ARGV.unshift(HELP_FLAG)
      end

      opt_parser.parse!

    rescue StandardError => e
      # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
      Logger.error("Error: #{e}")
    end
  end
end

AcctMg.run
