require 'securerandom'
require_relative 'sqlite_client'
require_relative 'logger'
require_relative 'formatter'

class SqliteDbUtil

  REQUIRED_TABLES = {:acct => 'acct',
                     :acct_desc => 'acct_desc',
                     :security_question => 'security_question',
                     :passcode => 'passcode'}

  # List all accounts.
  #
  # @return all accounts
  def self.list_all
    do_query('SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated, ad.link
              FROM acct a JOIN acct_desc ad on ad.acct_id = a.id ORDER BY a.date_updated;',
              %w(label id username password date_created date_updated link))
  end

  # Look up account detail by a given label.
  #
  # @param label the label of the account
  # @return the matched account
  def self.exact_find(label)
    do_query("SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated,
              ad.description, ad.link,
              sq.question, sq.answer,
              a.uuid FROM
              acct_desc ad JOIN acct a ON a.id = ad.acct_id LEFT JOIN security_question sq ON a.id = sq.acct_id
              WHERE ad.label like '#{label}' ORDER BY ad.date_updated;",
              %w(label id username password date_created date_updated description link question answer uuid))
  end

  # Look up uuid of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def self.find_uuid(label, field)
    account = find_and_choose(label, field)

    return account['uuid'] unless account.nil?
  end

  # Look up id of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the id of the selected account
  def self.find_acct_id(label, field)
    account = find_and_choose(label, field)

    return account['id'] unless account.nil?
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find_acct(label)
    results = exact_find(label)

    if results.length > 0
      return results
    else
      Logger.info("No account found with label: #{label}, attempt to fuzzy find...")
      fuzzy_results = exact_find("%#{label}%")

      if fuzzy_results.length <= 1
        return fuzzy_results
      else
        Logger.info("Found similar account with label: #{fuzzy_results[0]['label']}, list all similar results ? (Y/N)")
        decision = gets.chomp
        if /^[nN]/.match(decision)
          return fuzzy_results[0..0]
        else
          return fuzzy_results
        end
      end
    end
  end

  # Look up accounts by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def self.find_and_choose(label, field)
    select = 0
    result = find_acct(label)

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

    find_acct_query = table == REQUIRED_TABLES[:acct] ?
        "uuid = '#{uuid}'" : "acct_id = (SELECT id FROM acct WHERE uuid = '#{uuid}')"

    do_update("UPDATE #{table} SET #{field} = '#{new_val}', date_updated = CURRENT_TIMESTAMP WHERE #{find_acct_query};")
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @param header the column names
  # @param table the table
  # @return the execution result of the query
  def self.do_query(sql, header)
    client = SqliteClient.open

    if client.nil?
      raise StandardError.new('Issue creating SQLite connection')
    else
      Logger.debug("Executing query sql: '#{sql}'")
      result = client.execute(sql)

      client.close

      if result.nil? or result.empty?
        return []
      else
        return Formatter.format(mapping(header, result))
      end
    end
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @return the execution result of the query
  def self.do_update(sql)
    client = SqliteClient.open

    if client.nil?
      raise StandardError.new('Issue creating SQLite connection')
    else
      Logger.debug("Executing update sql: '#{sql}'")
      result = client.execute(sql)

      client.close
      return result
    end
  end

  # [ user_name, label, pwd ] + [ am, acct, hint ] => [ user_name: am, label: acct, pwd: hint ]
  #
  # @param header the names of each column of the table
  # @param result the query results
  # @param the query results with the column names
  def self.mapping(header, result)

    if header.length != result[0].length
      Logger.warn("Header length = #{header.length} not equal to entry length = #{result[0].length}, some fields will missing!")
    end

    result_with_header = []

    result.each do |values|
      entry = {}
      i = 0
      header.each do |key|
        entry[key] = values[i]
        i = i + 1
      end

      result_with_header.push(entry)
    end

    return result_with_header
  end
end
