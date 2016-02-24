require 'securerandom'
require_relative 'mysql_client'

class DbUtil
  # Add new account
  def self.add_new(label, username, password)
    puts("Adding new account: #{label}, username: #{username}")
    uuid = SecureRandom.hex(12)
    self.execute("INSERT INTO acct (uuid, username, password, date_updated, date_created) VALUES ('#{uuid}', '#{username}', '#{password}', NOW(), NOW());")
    self.execute("INSERT INTO acct_desc (label, date_updated, date_created, acct_id) VALUES ('#{label}', NOW(), NOW(), (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
  end

  # Find account information by label
  def self.find(label)
    puts("Looking up account: #{label}")
    self.execute("SELECT * FROM acct_desc ad JOIN acct a ON a.id = ad.acct_id WHERE ad.label = #{label} ORDER BY acct_desc.date_updated;")
  end

  def self.list_all
    puts('Listing all accounts')
    self.execute('SELECT * FROM acct_desc ORDER BY date_updated')
  end

  # Execute sql statement
  def self.execute(sql)
    client = MysqlClient.open

    unless client.nil?
      begin
        puts("Executing sql: #{sql}.")
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
