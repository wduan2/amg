#!/usr/bin/ruby

require 'mysql2'
require_relative 'utils/db_util'

class Main
  def self.run
    begin
      result = DbUtil.execute('SHOW tables;', [])
      puts(result.collect { |row| row.values })
    rescue Exception => e
      puts(e)
    end
  end
end

Main.run

