#!/usr/bin/ruby

require 'ap'
require 'optparse'
require_relative 'utils/logger'
require_relative 'utils/validator'
require_relative 'helpers/crud'
require_relative 'helpers/auth'
require_relative 'helpers/parser_helper'

class AcctMg

  HELP_FLAG = '--help'
  DEBUG_FLAG = '--debug'

  def self.print_result(result)
    len = 0

    if !result.nil? and result.length > 0
      ap result
      len = result.length
    end

    Logger.info("Total return accounts: #{len}")
  end

  def self.run
    while true
      Logger.info("User: #{Auth.get_user}, Possible commands: help, list, add, password, exit")

      # Ruby puts can parse special character without escape character

      # Split string by multiple whitespaces or commas
      # See also: http://stackoverflow.com/questions/13537920/ruby-split-by-whitespace
      input = gets.strip.split(/[\s,]+/m)

      # The parser only take two parameters, the operation and the parameters
      # Multiple parameters are saved in one string and separate by comma
      if input.include? 'help'
        ARGV.push('-h')
        self.cmd_run
      elsif input.include? 'list'
        ARGV.push('-l')
        self.cmd_run
      elsif input.include? 'add'
        ARGV.push('-a')
        ARGV.push(input[1..3].join(','))
        self.cmd_run
      elsif input.include? 'password'
        ARGV.push('-p')
        ARGV.push(input[1..2].join(','))
        self.cmd_run
      elsif input.include? 'exit'
        break
      end

      ARGV.clear

    end
    puts 'Bye'
  end

  def self.cmd_run
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
          print_result(Crud.list_all)
        end

        opts.on('-f', '--find [label]', 'find account') do |label|
          print_result(Crud.find_acct(label)) if Validator.validate_arg(label)
        end

        # Multiple arguments can not be separated by whitespace via STDIN
        opts.on('-a', '--add [label,username,password]', Array, 'add new account') do |acct_info|
          Crud.add_new(acct_info[0], acct_info[1], acct_info[2]) if Validator.validate_arg(acct_info)
        end

        opts.on('-q', '--question [label,question,answer]', Array, 'add new security question') do |qa_info|
          Crud.add_new_question(qa_info[0], qa_info[1], qa_info[2]) if Validator.validate_arg(qa_info)
        end

        opts.on('-d', '--delete [label]', 'delete accounts') do |label|
          Crud.delete(label) if Validator.validate_arg(label)
        end

        opts.on('-u', '--username [label,new_username]', Array, 'update the username') do |update|
          Crud.update_username(update[0], update[1]) if Validator.validate_arg(update)
        end

        opts.on('-p', '--password [label,new_password]', Array, 'update the password') do |update|
          Crud.update_password(update[0], update[1]) if Validator.validate_arg(update)
        end

        opts.on('-r', '--relabel [label,new_label]', Array, 'relabel the account') do |update|
          Crud.relabel(update[0], update[1]) if Validator.validate_arg(update)
        end
      end

      # STDIN doesn't work correctly for special characters like '!' or '\' unless they are escaped

      # Make sure the --debug or --help always get executed at first
      if ARGV.delete(DEBUG_FLAG)
        ARGV.unshift(DEBUG_FLAG)
      end

      if ARGV.empty?
        ARGV.unshift(HELP_FLAG)
      end

      ParserHelper.pre_process(ARGV)

      opt_parser.parse!(ARGV)

    rescue StandardError => e
      # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
      Logger.error("Error: #{e}")
    end
  end
end

if ARGV.length > 0
  AcctMg.cmd_run
else
  AcctMg.run
end
