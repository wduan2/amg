require 'securerandom'
require_relative 'mysql_client'

class DbUtil

  # Add new account.
  #
  # @param label the label of the account
  # @param username the username
  # @param password the password
  def self.add_new(label, username, password)
    puts("Adding new account: #{label}, username: #{username}")
    uuid = SecureRandom.hex(12)
    self.execute("INSERT INTO acct (uuid, username, password, date_updated, date_created) VALUES ('#{uuid}', '#{username}', '#{password}', NOW(), NOW());")
    self.execute("INSERT INTO acct_desc (label, date_updated, date_created, acct_id) VALUES ('#{label}', NOW(), NOW(), (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
  end

  # List all accounts.
  def self.list_all
    puts('Listing all accounts')
    self.execute('SELECT * FROM acct_desc ORDER BY date_updated')
  end

  # Look up account information by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find_acct(label)
    result = find(label)

    if result.to_a.length > 0
      return result
    else
      fuzzy_result = []
      return fuzzy_find(label, fuzzy_result, label.length - 1)
    end
  end

  # Look up account information by a given label.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find(label)
    puts("Looking up account with label: #{label}.")
    self.execute("SELECT * FROM acct_desc ad JOIN acct a ON a.id = ad.acct_id WHERE ad.label like '#{label}' ORDER BY ad.date_updated;")
  end

  # Look up account information by a given string recursively.
  #
  # @param string the label to look up
  # @param result the array of matched result
  # @param i the current index of the string used for fuzzy searching
  # @return the matched account
  def self.fuzzy_find(string, result, i)
    puts("No account found with label: #{string}, attempt to fuzzy find...")

    if i < 0
      result
    else
      self.find(string[0..i] << '%').to_a.each do |row|
        
        # Filter out duplicate results
        result.push(row) unless result.find { |i| i['uuid'] == row['uuid'] }
      end

      next_i = i - 1
      self.fuzzy_find(string, result, next_i)
    end
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @return the execution result of the query
  def self.execute(sql)
    client = MysqlClient.open

    unless client.nil?
      begin
        puts("Executing sql: '#{sql}'.")
        # Mysql2 has not support prepare statement yet
        result = client.query(sql)
      rescue Mysql2::Error => e
        MysqlClient.close
        raise Exception.new("Issue executing sql: '#{sql}', error: #{e}.")
      end
      # TODO: Figure out how does the 'ensure' block work
      MysqlClient.close
      return result
    end
  end
end
