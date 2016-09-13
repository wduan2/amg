require 'securerandom'
require_relative '../utils/db_util'
require_relative '../utils/sqlite_db_util'

class Crud

  def self.list_all2
    SqliteDbUtil.execute('SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated, ad.link
                          FROM acct a JOIN acct_desc ad on ad.acct_id = a.id ORDER BY a.date_updated;')
  end

  # Add new account.
  #
  # @param label the label of the account
  # @param username the username
  # @param password the password
  def self.add_new(label, username, password)
    uuid = SecureRandom.hex(12)
    DbUtil.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:acct]} (uuid, username, password, date_updated, date_created)
                    VALUES ('#{uuid}', '#{username}', '#{password}', NOW(), NOW());")
    DbUtil.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:acct_desc]} (label, date_updated, date_created, acct_id)
                    VALUES ('#{label}', NOW(), NOW(), (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
    Logger.info("New account: #{label}, username: #{username} added")
  end

  # Add new security question and answer.
  #
  # @param label the label of the account
  # @param question the question
  # @param answer the answer
  def self.add_new_question(label, question, answer)
    id = DbUtil.find_acct_id(label, nil)
    DbUtil.execute("INSERT INTO #{MysqlClient::REQUIRED_TABLES[:security_question]} (question, answer, date_created, date_updated, acct_id)
                    VALUES ('#{question}', '#{answer}', NOW(), NOW(), #{id});")
    Logger.info("New security question added for account with label: #{label}")
  end

  # Update username of the account.
  #
  # @param label the account label
  # @param new_username the new username
  def self.update_username(label, new_username)
    DbUtil.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct], 'username', new_username)
    Logger.info("Updated username for account with label: #{label}, new username: #{new_username}")
  end

  # Update password of the account.
  #
  # @param label the account label
  # @param new_password the new password
  def self.update_password(label, new_password)
    DbUtil.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct], 'password', new_password)
    Logger.info("Updated password for account with label: #{label}")
  end

  # Relabel the account.
  #
  # @param label the old label of the account
  # @param new_label the new label of the account
  def self.relabel(label, new_label)
    DbUtil.update_table_field(label, MysqlClient::REQUIRED_TABLES[:acct_desc], 'label', new_label)
    Logger.info("Updated account label to #{new_label}")
  end

  # Delete accounts with the given label.
  #
  # @param label the account label
  def self.delete(label)
    uuid = DbUtil.find_uuid(label, nil)
    DbUtil.execute("DELETE FROM acct WHERE uuid = '#{uuid}';")
    Logger.info("Account with label: #{label} deleted")
  end

  # List all accounts.
  def self.list_all
    DbUtil.execute('SELECT ad.label, a.id, a.username, a.password, a.date_created, a.date_updated, ad.link
                    FROM acct a JOIN acct_desc ad on ad.acct_id = a.id ORDER BY a.date_updated;')
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find_acct(label)
    results = DbUtil.exact_find(label)

    if results.length > 0
      return results
    else
      Logger.info("No account found with label: #{label}, attempt to fuzzy find...")
      fuzzy_results = DbUtil.fuzzy_find(label, [], label.length - 1)

      if fuzzy_results.length > 1
        Logger.info("Found similar account with label: #{fuzzy_results[0]['label']}, list all similar results ? (Y/N)")
        if /[nN]/.match(gets.chomp)
          return fuzzy_results[0..0]
        end
      end

      return fuzzy_results
    end
  end
end
