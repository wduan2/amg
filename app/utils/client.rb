require 'sqlite3'
require_relative 'logger'
require_relative 'validator'

module Client

  DB_FILE = "#{Dir.pwd}/app/data/am.db".freeze
  DB_INIT_SQL = File.read("#{Dir.pwd}/app/sql/create_sqlite.sql").to_s.freeze

  # Singleton sqlite client instance.
  @client = nil

  module_function

  # Return the sqlite client instance with database connection.
  #
  # @return the initialized sqlite client
  def open
    Logger.debug("Initializing SQLite database: #{DB_FILE}.")

    # Must create a new instance each time
    @client = SQLite3::Database.new(DB_FILE)
    @client.execute_batch(DB_INIT_SQL)

    return @client
  end

  # Close the database connection.
  def close
    @client.close unless @client.nil? && @client.closed?
    Logger.debug("Closing SQLite database: #{DB_FILE}.")
  end
end
