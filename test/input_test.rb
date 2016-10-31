require 'test/unit'
require_relative '../app/helpers/parser_helper'

class InputTest < Test::Unit::TestCase

  def test_parsing
    args = ['-u', 'label', 'usr', '--password', 'label', 'pwd', '--debug']

    ParserHelper.pre_process(args)

    assert_equal(args.length, 5)
    assert_equal(args[0], '-u')
    assert_equal(args[1], 'label,usr')
    assert_equal(args[2], '--password')
    assert_equal(args[3], 'label,pwd')
    assert_equal(args[4], '--debug')
  end
end
