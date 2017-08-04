require 'securerandom'
require_relative '../db/dao'

module Crud

  module_function

  # Add new account.
  #
  # @param label the label of the account
  # @param username the username
  # @param password the password
  def add_new(label, username, password)
    uuid = SecureRandom.hex(12)
    Dao.do_update("INSERT INTO #{Dao::REQUIRED_TABLES[:acct]} (uuid, username, password, date_updated, date_created, sys_user)
                            VALUES ('#{uuid}', '#{username}', '#{password}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '#{ENV['USER']}');")
    Dao.do_update("INSERT INTO #{Dao::REQUIRED_TABLES[:acct_desc]} (label, date_updated, date_created, acct_id)
                            VALUES ('#{label}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (SELECT id FROM acct WHERE uuid = '#{uuid}'));")
    Log.info("New account: #{label}, username: #{username} added")
  end

  # Add new security question and answer.
  #
  # @param label the label of the account
  # @param question the question
  # @param answer the answer
  def add_new_question(label, question, answer)
    id = Dao.find_acct_id(label, nil)
    Dao.do_update("INSERT INTO #{Dao::REQUIRED_TABLES[:security_question]} (question, answer, date_created, date_updated, acct_id)
                            VALUES ('#{question}', '#{answer}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, #{id});")
    Log.info("New security question added for account with label: #{label}")
  end

  # Update username of the account.
  #
  # @param label the account label
  # @param new_username the new username
  def update_username(label, new_username)
    Dao.update_table_field(label, Dao::REQUIRED_TABLES[:acct], 'username', new_username)
  end

  # Update password of the account.
  #
  # @param label the account label
  # @param new_password the new password
  def update_password(label, new_password)
    Dao.update_table_field(label, Dao::REQUIRED_TABLES[:acct], 'password', new_password)
  end

  # Relabel the account.
  #
  # @param label the old label of the account
  # @param new_label the new label of the account
  def relabel(label, new_label)
    Dao.update_table_field(label, Dao::REQUIRED_TABLES[:acct_desc], 'label', new_label)
  end

  # Delete accounts with the given label.
  #
  # @param label the account label
  def delete(label)
    uuid, found_label = Dao.find_uuid(label, nil)
    Dao.do_update("DELETE FROM acct WHERE uuid = '#{uuid}';")
    Log.info("Account with label: #{found_label} deleted")
  end

  # List all accounts.
  def list_all
    Dao.list_all
  end

  # Look up account detail by a given label, if no account found attempt to fuzzy search.
  #
  # @param label the label of the account
  # @return the matched account
  def find_acct(label)
    Dao.find_acct(label)
  end
end
