class TeamContentLog < ActiveRecord::Base
  def after_create
    begin
      Process.kill("USR1", IO.read(Rails.root + 'log/notification.rb.pid').chomp.to_i )
    rescue
    end
  end
end
