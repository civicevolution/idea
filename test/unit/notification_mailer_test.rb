require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test "periodic_report" do
    @expected.subject = 'NotificationMailer#periodic_report'
    @expected.body    = read_fixture('periodic_report')
    @expected.date    = Time.now

    assert_equal @expected.encoded, NotificationMailer.create_periodic_report(@expected.date).encoded
  end

  test "immediate_report" do
    @expected.subject = 'NotificationMailer#immediate_report'
    @expected.body    = read_fixture('immediate_report')
    @expected.date    = Time.now

    assert_equal @expected.encoded, NotificationMailer.create_immediate_report(@expected.date).encoded
  end

  test "settings_updated" do
    @expected.subject = 'NotificationMailer#settings_updated'
    @expected.body    = read_fixture('settings_updated')
    @expected.date    = Time.now

    assert_equal @expected.encoded, NotificationMailer.create_settings_updated(@expected.date).encoded
  end

end
