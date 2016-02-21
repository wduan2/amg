require 'securerandom'
require_relative 'mysql_client'

class DbUtil
  def self.add_new(label, username, password)
    puts("Adding new account: #{label}, username: #{username}")
    uuid = self.get_uuid
    self.execute("INSERT INTO acct (uuid, username, password, date_updated, date_created) VALUES ('#{uuid}', '#{username}', '#{password}', NOW(), NOW());")
    self.execute("INSERT INTO acct_desc (label, date_updated, date_created, acct_id) VALUES ('#{label}', NOW(), NOW(), (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
  end

  def self.list_all
    puts('Listing all accounts')
    self.execute('SELECT * FROM acct_desc ORDER BY date_updated')
  end

  def self.execute(sql)
    client = MysqlClient.open

    unless client.nil?
      begin
        puts("Executing sql: #{sql}.")
        result = client.query(sql)
      rescue Mysql2::Error => e
        MysqlClient.close
        raise Exception.new("Issue executing sql: '#{sql}', error: #{e}.")
      end
      MysqlClient.close
      return result
    end
  end

  def self.get_uuid
    SecureRandom.hex(12)
  end
end
