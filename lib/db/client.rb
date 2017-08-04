require 'sqlite3'
require_relative '../../lib/helper/log'
require_relative '../../lib/helper/validator'

module Client

  APP_PATH = File.absolute_path(File.dirname(__FILE__)).freeze

  DB_FILE = "#{APP_PATH}/am.db".freeze
  DB_INIT_SQL = File.read("#{APP_PATH}/am.sql").to_s.freeze

  # Singleton sqlite client instance.
  @client = nil

  module_function

  # Return the sqlite client instance with database connection.
  #
  # @return the initialized sqlite client
  def open
    unless File.exist? DB_FILE
      Log.debug("Initializing SQLite database: #{DB_FILE}")
      File.new(DB_FILE, 'w+')
      @client = SQLite3::Database.new(DB_FILE)
      @client.execute_batch(DB_INIT_SQL)
    end

    # Must create a new instance each time
    @client = SQLite3::Database.new(DB_FILE)
  end

  # Close the database connection.
  def close
    @client.close unless @client.nil? && @client.closed?
  end
end
