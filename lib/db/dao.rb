require 'securerandom'
require_relative 'client'
require_relative '../../lib/helper/log'
require_relative '../../lib/helper/formatter'

module Dao

  REQUIRED_TABLES = { acct: 'acct',
                      acct_desc: 'acct_desc',
                      security_question: 'security_question',
                      passcode: 'passcode' }.freeze

  module_function

  # List all accounts.
  #
  # @return all accounts
  def list_all
    do_query('SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated, ad.link
                  FROM acct a JOIN acct_desc ad on ad.acct_id = a.id ORDER BY a.date_updated;',
             %w[label id username password date_created date_updated link])
  end

  # Look up account detail by a given label.
  #
  # @param label the label of the account
  # @return the matched account
  def exact_find(label)
    do_query("SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated,
              ad.description, ad.link,
              sq.question, sq.answer,
              a.uuid, a.sys_user FROM
              acct_desc ad JOIN acct a ON a.id = ad.acct_id LEFT JOIN security_question sq ON a.id = sq.acct_id
              WHERE ad.label like '#{label}' AND a.sys_user = '#{ENV['USER']}'
              ORDER BY ad.date_updated;",
             %w[label id username password date_created date_updated description link question answer uuid sys_user])
  end

  # Look up uuid of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def find_uuid(label, field)
    account = find_and_choose(label, field)

    return account['uuid'], account['label'] unless account.nil?
  end

  # Look up id of an account by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the id of the selected account
  def find_acct_id(label, field)
    account = find_and_choose(label, field)

    account['id'] unless account.nil?
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def find_acct(label)
    results = exact_find(label)

    return results if results.any?

    Log.info("No account found with label: #{label}, attempt to fuzzy find...")
    fuzzy_results = exact_find("%#{label}%")

    return fuzzy_results if fuzzy_results.length <= 1

    Log.info("Found similar account with label: #{fuzzy_results[0]['label']}, list all similar results ? (Y/N)")

    decision = gets.chomp
    fuzzy_results[0..0] if decision =~ /^[nN]/
  end

  # Look up accounts by a given label, if multiple accounts found, let the user pick one.
  #
  # @param label the account label
  # @param field the field to update
  # @return the uuid of the selected account
  def find_and_choose(label, field)
    result = find_acct(label)

    if result.length > 1
      Log.info("More than one matched account with label : #{label} found:")

      pos = 0
      result.each do |acct|
        Log.info("#{pos}: UUID: #{acct['uuid']} Label: #{acct['label']} Link: #{acct['link']} Description: #{acct['description']} ")
        pos += 1
      end

      prompt = 'Choose one account'
      prompt += "to update #{field}" unless field.nil?

      Log.info(prompt + ':')
      select = gets.to_i
      return result[select]
    end

    result.first
  end

  # Update field with new value in table.
  #
  # @param label the account label
  # @param table the table to update
  # @param field the field to update
  # @param new_val the new value
  def update_table_field(label, table, field, new_val)
    uuid, found_label = find_uuid(label, field)

    if uuid.nil?
      Log.info("Account #{label} not found!")
      return
    end

    find_acct_query = table == REQUIRED_TABLES[:acct] ? "uuid = '#{uuid}'" : "acct_id = (SELECT id FROM acct WHERE uuid = '#{uuid}')"

    do_update("UPDATE #{table} SET #{field} = '#{new_val}', date_updated = CURRENT_TIMESTAMP WHERE #{find_acct_query};")

    Log.info("Update #{field} to #{new_val} for account #{found_label}")
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @param header the column names
  # @return the execution result of the query
  def do_query(sql, header)
    instance = Client.open

    raise StandardError, 'Issue creating SQLite connection' if instance.nil?

    Log.debug("Executing query sql: '#{sql}'")
    result = instance.execute(sql)

    instance.close

    return [] if result.nil? || result.empty?

    Formatter.format(mapping(header, result))
  end

  # Execute sql statement.
  #
  # @param sql the sql statement
  # @return the execution result of the query
  def do_update(sql)
    instance = Client.open

    raise StandardError, 'Issue creating SQLite connection' if instance.nil?

    Log.debug("Executing update sql: '#{sql}'")
    result = instance.execute(sql)

    instance.close

    result
  end

  # [ user_name, label, pwd ] + [ am, acct, hint ] => [ user_name: am, label: acct, pwd: hint ]
  #
  # @param header the names of each column of the table
  # @param result the query results
  def mapping(header, result)

    Log.warn("Header length = #{header.length} not equal to entry length = #{result[0].length}, some fields will missing!") if header.length != result[0].length

    result_with_header = []

    result.each do |values|
      entry = {}
      i = 0
      header.each do |key|
        entry[key] = values[i]
        i += 1
      end

      result_with_header.push(entry)
    end

    result_with_header
  end
end
