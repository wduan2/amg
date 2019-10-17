require_relative 'helper/log'
require_relative 'helper/validator'
require_relative 'helper/crud'
require 'fileutils'
require 'time'

module Amg
  class Cli
    include Validator
    include Log
    include Crud

    def print(result)
      if result.any?
        result.each do |acct|
          detail = ''
          acct.each do |k, v|
            detail += "  #{g(k)}: #{y(v.to_s)}\n"
          end
          log("#{detail}\n ------------------")
        end
      end

      info("Total return accounts: #{result.length}")
    end

    def start
      begin
        help_info = ['-h,--help                           | show help info',
                     '-l,--list                           | list all',
                     '-f,--find label                     | find account',
                     '-a,--add label username password    | add new account',
                     '-q,--question label question answer | add new security question',
                     '-d,--delete label                   | delete account',
                     '-u,--username label new_username    | update username',
                     '-p,--password label new_password    | update password',
                     '-r,--relabel label new_label        | update label'].join("\n")
        cmds = []

        while ARGV.any?
          opt = ARGV.shift
          case opt
          when '--debug'
            enable_debug
          when '-l' || '--list'
            cmds << proc { print(list_all) }
          when '-f' || '--find'
            label = next?(ARGV, 'invalid label, usage: -f,--find label')
            cmds << proc { print(find_acct(label)) }
          when '-a' || '--add'
            acct_info = next_n?(ARGV, 3, 'invalid arguments, usage: -a,--add label username password')
            cmds << proc { add_new(acct_info[0], acct_info[1], acct_info[2]) }
          when '-q' || '--question'
            acct_info = next_n?(ARGV, 3, 'invalid arguments, usage: -q,--question label question answer')
            cmds << proc { add_new_question(acct_info[0], acct_info[1], acct_info[2]) }
          when '-d' || '--delete'
            label = next?(ARGV, 'invalid label, usage: -d,--delete label')
            cmds << proc { delete(label) }
          when '-di'
            uuid = next?(ARGV, 'invalid uuid, usage -di uuid')
            cmds << proc { delete_by_uuid(uuid) }
          when '-u' || '--username'
            acct_info = next_n?(ARGV, 2, 'invalid arguments, usage: -u label new_username')
            cmds << proc { update_username(acct_info[0], acct_info[1]) }
          when '-p' || '--password'
            acct_info = next_n?(ARGV, 2, 'invalid arguments, usage: -p label new_password')
            cmds << proc { update_password(acct_info[0], acct_info[1]) }
          when '-r' || '--relabel'
            acct_info = next_n?(ARGV, 2, 'invalid arguments, usage: -r label new_label')
            cmds << proc { relabel(acct_info[0], acct_info[1]) }
          when '-b' || '--backup'
            cmds << proc { backup }
          else
            raise "Unknown argument: #{opt}\n#{help_info}"
          end
        end

        cmds.each(&:call)

      rescue RuntimeError => e
        # Cannot catch 'Exception' since system exit is one kind of 'Exception' in ruby
        error("Error: #{e}")
        exit(1)
      end
    end

    def backup
      backup_path = "#{ENV['HOME']}/.acct/backup"
      FileUtils.mkdir_p(backup_path) unless File.directory?(backup_path)

      backups = Dir["#{backup_path}/*"]
      backups.each do |backup|
        if backups.size > 4 && File.ctime(backup).utc + (7 * 24 * 60 * 60) < Time.now.utc
          FileUtils.remove(backup)
        end
      end

      FileUtils.copy("#{ENV['HOME']}/.acct/am.db", "#{ENV['HOME']}/.acct/backup/am-#{Date.today}.db")
    end
  end
end

Amg::Cli.new.start
