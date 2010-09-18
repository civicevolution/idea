require 'test_helper'

class MemberMailerTest < ActionMailer::TestCase
  test "confirm" do
    @expected.subject = 'MemberMailer#confirm'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MemberMailer.create_confirm(@expected.date).encoded
  end

  test "reset_password" do
    @expected.subject = 'MemberMailer#reset_password'
    @expected.body    = read_fixture('reset_password')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MemberMailer.create_reset_password(@expected.date).encoded
  end

end
