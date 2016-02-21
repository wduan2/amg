require_relative 'mysql_client'

class DbUtil
  def self.add_new(label, username, password)
    puts("Adding new account: #{label}, username: #{username}")
    self.execute('INSERT INTO acct (username, password, date_updated, date_created) VALUES (?, ?, NOW(), NOW());', [username, password])
    self.execute('INSERT INTO acct_desc (label, date_updated, date_created) VALUES (?, NOW(), NOW());', label)
  end

  def self.list_all
    puts('Listing all accounts')
    self.execute('SELECT * FROM acct_desc ORDER BY date_updated', [])
  end

  def self.execute(sql, args)
    client = MysqlClient.open

    unless client.nil?
      begin
        puts("Executing sql: #{sql} with args: #{args}.")
        ps = client.prepare(sql)
        arg_list = ([] << args).flatten
        result = ps.execute(*arg_list)
      rescue Mysql2::Error => e
        raise Exception.new("Issue executing sql: '#{sql}', error: #{e}.")
      ensure
        puts('Closing connection.')
        MysqlClient.close
        return result
      end
    end
  end
end
