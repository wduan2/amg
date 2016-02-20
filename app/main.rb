#!/usr/bin/ruby

require 'mysql2'
require_relative 'utils/db_util'

class Main
  def self.run
    result = DbUtil.execute('SHOW databases;', [])
    unless result.nil?
      result.each do |row|
        puts(row)
      end
    end
  end
end

Main.run
