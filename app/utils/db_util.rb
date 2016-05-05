require 'securerandom'
require_relative 'mysql_client'
require_relative 'common_util'

class DbUtil

  # Add new account.
  #
  # @param label the label of the account
  # @param username the username
  # @param password the password
  def self.add_new(label, username, password)
    uuid = SecureRandom.hex(12)
    self.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:acct]} (uuid, username, password, date_updated, date_created)
                  VALUES ('#{uuid}', '#{username}', '#{password}', NOW(), NOW());")
    self.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:acct_desc]} (label, date_updated, date_created, acct_id)
                  VALUES ('#{label}', NOW(), NOW(), (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
    CommonUtil.log_important("New account: #{label}, username: #{username} added")
  end

  # Add new security question and answer.
  #
  # @param label the label of the account
  # @param question the question
  # @param answer the answer
  def self.add_new_question(label, question, answer)
    id = find_acct_id(label, nil)
    self.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:security_question]} (question, answer, date_created, date_updated, acct_id)
                  VALUES ('#{question}', '#{answer}', NOW(), NOW(), #{id});")
    CommonUtil.log_important("New security question added for account with label: #{label}")
  end

  # Update username of the account.
  #
  # @param label the account label
  # @param new_username the new username
  def self.update_username(label, new_username)
    self.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct], 'username', new_username)
    CommonUtil.log_important("Updated username for account with label: #{label}, new username: #{new_username}")
  end

  # Update password of the account.
  #
  # @param label the account label
  # @param new_password the new password
  def self.update_password(label, new_password)
    self.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct], 'password', new_password)
    CommonUtil.log_important("Updated password for account with label: #{label}")
  end

  # Relabel the account.
  #
  # @param label the old label of the account
  # @param new_label the new label of the account
  def self.relabel(label, new_label)
    self.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct_desc], 'label', new_label)
    CommonUtil.log_important("Updated account label to #{new_label}")
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

  # Delete accounts with the given label.
  #
  # @param label the account label
  def self.delete(label)
    uuid = find_uuid(label, nil)
    self.execute("DELETE FROM acct WHERE uuid = '#{uuid}';")
    CommonUtil.log_important("Account with label: #{label} deleted")
  end

  # List all accounts.
  def self.list_all
    self.execute('SELECT a.username, a.password, ad.label, ad.link
                  FROM acct a JOIN acct_desc ad on ad.acct_id = a.id ORDER BY a.date_updated;')
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find_acct(label)
    result = exact_find(label)

    if result.length > 0
      return result
    else
      puts("No account found with label: #{label}, attempt to fuzzy find...")
      fuzzy_result = fuzzy_find(label, [], label.length - 1)

      if fuzzy_result.length > 1
        puts("Found similar account with label: #{fuzzy_result[0]['label']}, list all similar results ? (Y/N)")
        if /[nN]/.match(gets.chomp)
          return fuzzy_result[0..0]
        end
      end

      return fuzzy_result
    end
  end

  # Look up account detail by a given label.
  #
  # @param label the label of the account
  # @return the matched account
  def self.exact_find(label)
    return self.execute("SELECT * FROM acct_desc ad JOIN acct a ON a.id = ad.acct_id WHERE ad.label like '#{label}' ORDER BY ad.date_updated;")
  end

  # Look up account detail by a given string recursively.
  #
  # @param string the label to look up
  # @param result the array of matched result
  # @param i the current index of the string used for fuzzy searching
  # @return the matched account
  def self.fuzzy_find(string, result, i)
    if i < 0
      puts("No account with label: #{string} found in database by fuzzy search") if result.length == 0
      result
    else
      self.exact_find(string[0..i] << '%').each do |acct|

        # Filter out duplicate results
        result.push(acct) unless result.find { |i| i['uuid'] == acct['uuid'] }
      end

      next_i = i - 1
      self.fuzzy_find(string, result, next_i)
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
      puts("More than one matched account with label : #{label} found:")

      pos = 0
      result.each do |acct|
        puts("#{pos}: UUID: #{acct['uuid']} Label: #{acct['label']} Link: #{acct['link']} Description: #{acct['description']} ")
        pos = pos + 1
      end

      prompt = 'Choose one account'
      unless field.nil?
        prompt = prompt + "to update #{field}"
      end
      puts(prompt + ':')
      select = gets.to_i
    end

    return result[select]
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
        CommonUtil.log_debug("Executing sql: '#{sql}'")
        # Mysql2 has not support prepare statement yet
        result = client.query(sql)
      rescue Mysql2::Error => e
        MysqlClient.close
        raise StandardError.new("Issue executing sql: '#{sql}', error: #{e}")
      end
      MysqlClient.close
      return result.to_a
    end
  end
end
