require 'sqlite3'
require_relative 'logger'
require_relative 'validator'

class SqliteClient

  DB_NAME = File.expand_path('../../data/am.db', __FILE__).to_s.freeze
  DB_CREATE_SQL = File.expand_path('../../sql/create_sqlite.sql', __FILE__).to_s.freeze

  # Singleton sqlite client instance.
  @client = nil

  # Return the sqlite client instance with database connection.
  #
  # @return the initialized sqlite client
  def open
    Logger.debug("Initializing SQLite database: #{DB_NAME}.")

    # Update the table. TODO: any API to do this ?
    `sqlite3 #{DB_NAME} < #{DB_CREATE_SQL}`

    @client = SQLite3::Database.new(DB_NAME)
  end

  # Close the database connection.
  def close
    @client.close unless @client.nil? && @client.closed?
    Logger.debug("Closing SQLite database: #{DB_NAME}.")
  end
end
