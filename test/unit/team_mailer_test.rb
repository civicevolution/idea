require 'test_helper'

class TeamMailerTest < ActionMailer::TestCase
  test "teammate_message" do
    @expected.subject = 'TeamMailer#teammate_message'
    @expected.body    = read_fixture('teammate_message')
    @expected.date    = Time.now

    assert_equal @expected.encoded, TeamMailer.create_teammate_message(@expected.date).encoded
  end

end
