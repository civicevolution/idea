require 'test_helper'

class HelpMailerTest < ActionMailer::TestCase
  test "help_request_receipt" do
    @expected.subject = 'HelpMailer#help_request_receipt'
    @expected.body    = read_fixture('help_request_receipt')
    @expected.date    = Time.now

    assert_equal @expected.encoded, HelpMailer.create_help_request_receipt(@expected.date).encoded
  end

  test "help_request_review" do
    @expected.subject = 'HelpMailer#help_request_review'
    @expected.body    = read_fixture('help_request_review')
    @expected.date    = Time.now

    assert_equal @expected.encoded, HelpMailer.create_help_request_review(@expected.date).encoded
  end

end
