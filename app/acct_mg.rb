#!/usr/bin/ruby

require 'ap'
require_relative 'utils/logger'
require_relative 'utils/validator'
require_relative 'helpers/crud'
require_relative 'helpers/auth'

def print(result)
  ap result if result.any?

  Logger.info("Total return accounts: #{result.length}")
end

begin
  cmds = []

  while ARGV.any?
    case ARGV.shift
    when '--debug'
      Logger.enable_debug
    when '-h' || '--help'
      puts '-h,--help -- show help info
            -l,--list -- list all
            -f,--find label -- find account
            -a,--add label username password -- add new account
            -q,--question label question answer -- add new security question
            -d,--delete label -- delete account
            -u,--username label new_username -- update username
            -p,--password label new_password -- update password
            -r,--relabel label new_label -- update label
            -b,--backup -- backup db'

    when '-l' || '--list'
      cmds << proc { print(Crud.list_all) }
    when '-f' || '--find'
      label = ARGV.shift
      cmds << proc { print(Crud.find_acct(label)) } if Validator.test(label)
    when '-a' || '--add'
      acct_info = ARGV.shift(3)
      cmds << proc { Crud.add_new(acct_info[0], acct_info[1], acct_info[2]) } if Validator.test(acct_info)
    when '-q' || '--question'
      acct_info = ARGV.shift(3)
      cmds << proc { Crud.add_new_question(acct_info[0], acct_info[1], acct_info[2]) } if Validator.test(acct_info)
    when '-d' || '--delete'
      label = ARGV.shift
      cmds << proc { Crud.delete(label) } if Validator.test(label)
    when '-u' || '--username'
      acct_info = ARGV.shift(2)
      cmds << proc { Crud.update_username(acct_info[0], acct_info[1]) } if Validator.test(acct_info)
    when '-p' || '--password'
      acct_info = ARGV.shift(2)
      cmds << proc { Crud.update_password(acct_info[0], acct_info[1]) } if Validator.test(acct_info)
    when '-r' || '--relabel'
      acct_info = ARGV.shift(2)
      cmds << proc { Crud.relabel(acct_info[0], acct_info[1]) } if Validator.test(acct_info)
    else
      ARGV.shift
    end

    cmds.each(&:call)
  end
rescue => e
  # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
  Logger.error("Error: #{e}\nBacktrace: #{e.backtrace}")
end
