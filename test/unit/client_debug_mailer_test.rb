require 'test_helper'

class ClientDebugMailerTest < ActionMailer::TestCase
  test "ape_restart" do
    @expected.subject = 'ClientDebugMailer#ape_restart'
    @expected.body    = read_fixture('ape_restart')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ClientDebugMailer.create_ape_restart(@expected.date).encoded
  end

  test "report_filed" do
    @expected.subject = 'ClientDebugMailer#report_filed'
    @expected.body    = read_fixture('report_filed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ClientDebugMailer.create_report_filed(@expected.date).encoded
  end

end
