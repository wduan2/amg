require 'mysql2'

# Util class for creating mysql client instance
class MysqlClient
  # Singleton mysql client instance
  @@client = nil

  # Return the mysql client instance
  def self.open(host = 'localhost', port = '3306', database = 'am', username = 'root', password = '')
    self.close
    self.init(host, port, database, username, password)

    return @@client
  end

  # Create mysql client instance
  def self.init(host, port, database, username, password)
    if @@client.nil?
      begin
        puts("Establishing mysql client instance, host: #{host}, port: #{port}, database: #{database}, username: #{username}.")
        @@client = Mysql2::Client.new(:host => host, :port => port, :database => database, :username => username, :password => password)
      rescue Mysql2::Error => e
        puts("Issue establishing mysql client, error: #{e}.")
        self.close
      end
    end
  end

  # Close the  mysql client
  def self.close
    puts('Closing mysql client...')
    @@client.close if @@client
  end
end