require 'mysql2'

# Util class for creating mysql client instance.
class MysqlClient

  # Singleton mysql client instance.
  @client = nil

  # Flag to indicate if the database has been initialized.
  @initialized = false

  # Return the mysql client instance with mysql connection.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  # @return the initialized mysql client
  def self.open(host = 'localhost', port = '3306', database = 'am', username = 'root', password = '')
    self.close
    unless @initialized
      init_db(host, port, database, username, password)
    end
    connect(host, port, database, username, password)

    return @client
  end

  # Close the mysql client.
  def self.close
    @client.close if @client
  end

  # Open a new mysql connection.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  def self.connect(host, port, database, username, password)
    begin
      puts("Establishing mysql client instance, host: #{host}, port: #{port}, database = #{database}, username: #{username}.")
      @client = Mysql2::Client.new(:host => host, :port => port, :database => database, :username => username, :password => password)
    rescue Mysql2::Error => e
      self.close
      raise Exception.new("Issue establishing mysql client, error: #{e}.")
    end
  end

  # Initialize the mysql client.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  def self.init_db(host, port, database, username, password)
    puts("Using database: #{database}.")

    begin
      client = connect(host, port, nil, username, password)
      result = client.query('SHOW databases;').collect { |row| row.values }.flatten

      if result.include?(database)
        puts("Database: #{database} exists, connecting...")
        @initialized = true
      else
        puts("Database: #{database} doesn't exist, creating...")
        client.query("CREATE database #{database};")
        puts("Initializing database: #{database}.")
        `mysql -u root #{database} < #{Dir.pwd}/sql/create.sql;`
        @initialized = true
      end
    rescue Mysql2::Error => e
      self.close
      raise Exception.new("Issue initializing database: #{database}, error: #{e}.")
    end
    self.close
  end
end
