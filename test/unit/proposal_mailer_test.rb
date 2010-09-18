require 'test_helper'

class ProposalMailerTest < ActionMailer::TestCase
  test "submit_receipt" do
    @expected.subject = 'ProposalMailer#submit_receipt'
    @expected.body    = read_fixture('submit_receipt')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ProposalMailer.create_submit_receipt(@expected.date).encoded
  end

  test "review_request" do
    @expected.subject = 'ProposalMailer#review_request'
    @expected.body    = read_fixture('review_request')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ProposalMailer.create_review_request(@expected.date).encoded
  end

  test "approval_notice" do
    @expected.subject = 'ProposalMailer#approval_notice'
    @expected.body    = read_fixture('approval_notice')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ProposalMailer.create_approval_notice(@expected.date).encoded
  end

end
