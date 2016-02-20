require_relative 'mysql_client'

class DbUtil
  def self.execute(sql, args)
    client = MysqlClient.open

    unless client.nil?
      begin
        puts("Executing sql: #{sql} with args: #{args}.")
        ps = client.prepare(sql)
        result = ps.execute(*args)
      rescue Mysql2::Error => e
        puts("Issue executing sql: '#{sql}', error: #{e}.")
      ensure
        MysqlClient.close
        return result
      end
    end
  end
end