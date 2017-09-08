require_relative 'helper/log'
require_relative 'helper/validator'
require_relative 'helper/crud'
require 'fileutils'

module Amg
  class Cli
    def print(result)
      if result.any?
        result.each do |acct|
          detail = ''
          acct.each do |k, v|
            detail += "  #{Log.g(k)}: #{Log.y(v.to_s)}\n"
          end
          Log.log("#{detail}\n ------------------")
        end
      end

      Log.info("Total return accounts: #{result.length}")
    end

    def start
      begin
        cmds = []

        while ARGV.any?
          case ARGV.shift
          when '--debug'
            Log.enable_debug
          when '-h' || '--help'
            puts ['-h,--help                           | show help info',
                  '-l,--list                           | list all',
                  '-f,--find label                     | find account',
                  '-a,--add label username password    | add new account',
                  '-q,--question label question answer | add new security question',
                  '-d,--delete label                   | delete account',
                  '-u,--username label new_username    | update username',
                  '-p,--password label new_password    | update password',
                  '-r,--relabel label new_label        | update label'].join("\n")
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
          when '-b' || '--backup'
            cmds << proc { FileUtils.copy("#{File.absolute_path(File.dirname(__FILE__))}/db/am.db", "#{ENV['HOME']}/.acct/am-#{Date.today}.db") }
          else
            ARGV.shift
          end
        end

        cmds.each(&:call)

      rescue => e
        # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
        Log.error("Error: #{e}\nBacktrace: #{e.backtrace}")
      end
    end
  end
end

Amg::Cli.new.start