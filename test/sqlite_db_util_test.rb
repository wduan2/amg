require 'test/unit'
require_relative '../app/utils/sqlite_db_util'

class SqliteDbUtilTest < Test::Unit::TestCase

  def test_mapping
    result = [[ 'am1', 'myAccount', 'myPwd' ], [ 'am2', 'anotherAccount', 'noClue' ]]
    header = [ 'user_name', 'label', 'pwd' ]
    expect = [{ 'user_name' => 'am1', 'label' => 'myAccount', 'pwd' => 'myPwd' },
              { 'user_name' => 'am2', 'label' => 'anotherAccount', 'pwd' => 'noClue' }]

    actual = SqliteDbUtil.mapping(header, result)

    assert_empty(expect - actual)
  end
end
