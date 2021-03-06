require 'test/unit'
require_relative '../lib/db/dao'

class DaoTest < Test::Unit::TestCase

  def test_mapping
    result = [%w[am1 myAccount myPwd], %w[am2 anotherAccount noClue]]
    header = %w[user_name label pwd]
    expect = [{ 'user_name' => 'am1', 'label' => 'myAccount', 'pwd' => 'myPwd' },
              { 'user_name' => 'am2', 'label' => 'anotherAccount', 'pwd' => 'noClue' }]

    actual = Dao.mapping(header, result)

    assert_empty(expect - actual)
  end
end
