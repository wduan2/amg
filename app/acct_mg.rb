#!/usr/bin/ruby

require 'ap'
require_relative 'utils/logger'
require_relative 'utils/validator'
require_relative 'helpers/crud'
require_relative 'helpers/auth'

class AcctMg

  def self.print_result(result)
    result = [] if result.nil?
    ap result

    Logger.info("Total return accounts: #{result.length}")
  end

  def self.run
    begin
      while ARGV.any?
        case ARGV.shift
        when '--debug'
          Logger.enable_debug
        when '-h' || '--help'
          puts "-h,--help -- show help info
                -l,--list -- list all
                -f,--find label -- find account
                -a,--add label username password -- add new account
                -q,--question label question answer -- add new security question
                -d,--delete label -- delete account
                -u,--username label new_username -- update username
                -p,--password label new_password -- update password
                -r,--relabel label new_label -- update label"
        when '-l' || '--list'
          print_result(Crud.list_all)
        when '-f' || '--find'
          label = ARGV.shift
          print_result(Crud.find_acct(label)) if Validator.validate_arg(label)
        when '-a' || '--add'
          acct_info = ARGV.shift(3)
          Crud.add_new(acct_info[0], acct_info[1], acct_info[2]) if Validator.validate_arg(acct_info)
        when '-q' || '--question'
          acct_info = ARGV.shift(3)
          Crud.add_new_question(acct_info[0], acct_info[1], acct_info[2]) if Validator.validate_arg(acct_info)
        when '-d' || '--delete'
          label = ARGV.shift
          Crud.delete(label) if Validator.validate_arg(label)
        when '-u' || '--username'
          acct_info = ARGV.shift(2)
          Crud.update_username(acct_info[0], acct_info[1]) if Validator.validate_arg(acct_info)
        when '-p' || '--password'
          acct_info = ARGV.shift(2)
          Crud.update_password(acct_info[0], acct_info[1]) if Validator.validate_arg(acct_info)
        when '-r' || '--relabel'
          acct_info = ARGV.shift(2)
          Crud.relabel(acct_info[0], acct_info[1]) if Validator.validate_arg(acct_info)
        else
          ARGV.shift
        end
      end
    rescue StandardError => e
      # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
      Logger.error("Error: #{e}")
    end
  end
end

AcctMg.run
