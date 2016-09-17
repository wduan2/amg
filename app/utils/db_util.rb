require_relative 'mysql_client'
require_relative 'logger'
require_relative 'formatter'

# Deprecated, use SqliteDbUtil instead
# Internal used database functions.
class DbUtil

  # Look up account detail by a given label.
  #
  # @param label the label of the account
  # @return the matched account
  def self.exact_find(label)
    return self.execute("SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated,
                         ad.description, ad.link,
                         sq.question, sq.answer,
                         a.uuid FROM
                         acct_desc ad JOIN acct a ON a.id = ad.acct_id LEFT JOIN security_question sq ON a.id = sq.acct_id
                         WHERE ad.label like '#{label}' ORDER BY ad.date_updated;")
  end

  # Look up account detail by a given string recursively.
  #
  # @param string the label to look up
  # @param results the array of matched result
  # @param i the current index of the string used for fuzzy searching
  # @return the matched account
  def self.fuzzy_find(string, results, i)
    if i < 0
      Logger.info("No account with label: #{string} found in database by fuzzy search") if results.length == 0
      return results
    else
      self.exact_find(string[0..i] << '%').each do |acct|

        # Filter out duplicate results
        unless results.find { |result| result['uuid'] == acct['uuid'] }
          results.push(acct)
        end
      end

      next_i = i - 1
      self.fuzzy_find(string, results, next_i)
    end
  end

  # Look up uuid of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def self.find_uuid(label, field)
    account = self.find_and_choose(label, field)

    return account['uuid'] unless account.nil?
  end

  # Look up id of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the id of the selected account
  def self.find_acct_id(label, field)
    account = self.find_and_choose(label, field)

    return account['id'] unless account.nil?
  end

  # Look up accounts by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def self.find_and_choose(label, field)
    select = 0
    result = self.find_acct(label)

    if result.length > 1
      Logger.info("More than one matched account with label : #{label} found:")

      pos = 0
      result.each do |acct|
        Logger.info("#{pos}: UUID: #{acct['uuid']} Label: #{acct['label']} Link: #{acct['link']} Description: #{acct['description']} ")
        pos = pos + 1
      end

      prompt = 'Choose one account'
      unless field.nil?
        prompt = prompt + "to update #{field}"
      end
      Logger.info(prompt + ':')
      select = gets.to_i
    end

    return result[select]
  end

  # Update field with new value in table.
  #
  # @param label the account label
  # @param table the table to update
  # @param field the field to update
  # @param new_val the new value
  def self.update_table_field(label, table, field, new_val)
    uuid = find_uuid(label, field)

    find_acct_query = table == MysqlClient::REQUIRED_TABLES[:acct] ?
        "uuid = '#{uuid}'" : "acct_id = (SELECT id FROM acct WHERE uuid = '#{uuid}')"

    self.execute("UPDATE #{table} SET #{field} = '#{new_val}', date_updated = NOW() WHERE #{find_acct_query};")
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @return the execution result of the query
  def self.execute(sql)
    client = MysqlClient.open

    if client.nil?
      raise StandardError.new('Issue creating mysql connection')
    else
      begin
        Logger.debug("Executing sql: '#{sql}'")
        # Mysql2 has not support prepare statement yet
        result = Formatter.format(client.query(sql))
      rescue Mysql2::Error => e
        MysqlClient.close
        raise StandardError.new("Issue executing sql: '#{sql}', error: #{e}")
      end
      MysqlClient.close
      return result.to_a
    end
  end
end
