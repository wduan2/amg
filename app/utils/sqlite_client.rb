require 'sqlite3'
require_relative 'logger'
require_relative 'validator'

class SqliteClient

  DB_NAME = "#{File.expand_path('../../data/am.db', __FILE__)}"
  DB_CREATE_SQL = "#{File.expand_path('../../sql/create_sqlite.sql', __FILE__)}"

  # Singleton sqlite client instance.
  @client = nil

  # Return the sqlite client instance with database connection.
  #
  # @return the initialized sqlite client
  def self.open
    Logger.debug("Initializing SQLite database: #{DB_NAME}.")

    # Update the table. TODO: any API to do this ?
    `sqlite3 #{DB_NAME} < #{DB_CREATE_SQL}`

    @client = SQLite3::Database.new(DB_NAME)
  end

  # Close the database connection.
  def self.close
    unless @client.nil? and @client.closed?
      Logger.debug("Closing SQLite database: #{DB_NAME}.")

      @client.close
    end
  end
end
