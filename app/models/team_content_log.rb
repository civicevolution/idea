class TeamContentLog < ActiveRecord::Base
  
  after_create :send_signal_to_daemon
  
  def send_signal_to_daemon
    begin
      Process.kill("USR1", IO.read(Rails.root + 'log/notification.rb.pid').chomp.to_i )
    rescue
    end
  end
end
