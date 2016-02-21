#!/usr/bin/ruby

require 'mysql2'
require_relative 'utils/db_util'

class Main
  def self.run
    begin
      puts('label = ')
      label = gets.chomp
      puts('username = ')
      username = gets.chomp
      puts('password = ')
      password = gets.chomp
      DbUtil.add_new(label, username, password)

      result = DbUtil.list_all
      result.each do |row|
        puts(row)
      end
    rescue Exception => e
      puts("Exception: #{e}")
    end
  end
end

Main.run

