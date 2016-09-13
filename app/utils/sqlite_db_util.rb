require 'securerandom'
require_relative 'sqlite_client'
require_relative 'logger'
require_relative 'formatter'

class SqliteDbUtil

  def self.execute(sql)
    client = SqliteClient.open

    if client.nil?
      raise StandardError.new('Issue creating SQLite connection')
    else
      Logger.debug("Executing sql: '#{sql}'")
      result = client.execute(sql)
    end

    client.close
    return result
  end
end
