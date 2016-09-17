require 'securerandom'
require_relative '../utils/db_util'
require_relative '../utils/sqlite_db_util'

class Crud

  # Add new account.
  #
  # @param label the label of the account
  # @param username the username
  # @param password the password
  def self.add_new(label, username, password)
    uuid = SecureRandom.hex(12)
    SqliteDbUtil.do_update("INSERT INTO #{SqliteDbUtil::REQUIRED_TABLES[:acct]} (uuid, username, password, date_updated, date_created)
                            VALUES ('#{uuid}', '#{username}', '#{password}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);")
    SqliteDbUtil.do_update("INSERT INTO #{SqliteDbUtil::REQUIRED_TABLES[:acct_desc]} (label, date_updated, date_created, acct_id)
                            VALUES ('#{label}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
    Logger.info("New account: #{label}, username: #{username} added")
  end

  # Add new security question and answer.
  #
  # @param label the label of the account
  # @param question the question
  # @param answer the answer
  def self.add_new_question(label, question, answer)
    id = SqliteDbUtil.find_acct_id(label, nil)
    SqliteDbUtil.do_update("INSERT INTO #{SqliteDbUtil::REQUIRED_TABLES[:security_question]} (question, answer, date_created, date_updated, acct_id)
                            VALUES ('#{question}', '#{answer}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, #{id});")
    Logger.info("New security question added for account with label: #{label}")
  end

  # Update username of the account.
  #
  # @param label the account label
  # @param new_username the new username
  def self.update_username(label, new_username)
    SqliteDbUtil.update_table_field(label, SqliteDbUtil::REQUIRED_TABLES[:acct], 'username', new_username)
    Logger.info("Updated username for account with label: #{label}, new username: #{new_username}")
  end

  # Update password of the account.
  #
  # @param label the account label
  # @param new_password the new password
  def self.update_password(label, new_password)
    DbUtil.update_table_field(label, SqliteDbUtil::REQUIRED_TABLES[:acct], 'password', new_password)
    Logger.info("Updated password for account with label: #{label}")
  end

  # Relabel the account.
  #
  # @param label the old label of the account
  # @param new_label the new label of the account
  def self.relabel(label, new_label)
    SqliteDbUtil.update_table_field(label, SqliteDbUtil::REQUIRED_TABLES[:acct_desc], 'label', new_label)
    Logger.info("Updated account label to #{new_label}")
  end

  # Delete accounts with the given label.
  #
  # @param label the account label
  def self.delete(label)
    uuid = SqliteDbUtil.find_uuid(label, nil)
    SqliteDbUtil.do_update("DELETE FROM acct WHERE uuid = '#{uuid}';")
    Logger.info("Account with label: #{label} deleted")
  end

  # List all accounts.
  def self.list_all
    SqliteDbUtil.list_all
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def self.find_acct(label)
    SqliteDbUtil.find_acct(label)
  end
end
