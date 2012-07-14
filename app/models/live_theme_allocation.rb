class LiveThemeAllocation < ActiveRecord::Base
  
  attr_accessible :session_id, :theme_id, :table_id, :voter_id, :points
  
  def self.save_votes(session_id, table_id, voter_id, votes)
    # check that the votes are allowed limits
    vote_sum = 0
    vote_over = false
    vote_under = false

    votes.each_value do |points|
      vote_over = true if points > 30
      vote_under = true if points < 0
      vote_sum += points
    end

    err_msgs = {}
    if vote_sum > 100
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You cannot allocate more than \$100"
    end
    if vote_sum <= 0
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You must allocate at least \$1"
    end
    if vote_over
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You cannot allocate more than \$40 to any single idea"
    end
    if vote_under
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You cannot allocate less than \$0 to an idea"
    end

    if err_msgs.empty?
      
      # if no voter_id is provided, generate the next one for this table
      if voter_id.nil? || voter_id.length == 0
        voter_id = LiveThemeAllocation.where(:session_id=>session_id, :table_id=>table_id).maximum(:voter_id)
        voter_id = voter_id.nil? ? 1 : voter_id + 1
      end

      LiveThemeAllocation.delete_all(:session_id => session_id, :table_id=>table_id, :voter_id => voter_id)
      votes.each_pair do |theme_id, points|
        LiveThemeAllocation.create( :session_id => session_id, :table_id=>table_id, :voter_id => voter_id, :theme_id=> theme_id, :points => points )
      end

      return true, voter_id, nil
    else
      return false, nil, err_msgs
    end

  end
  
  def self.get_voters(session_id, table_id)
    @voters = ActiveRecord::Base.connection.select_values(%Q|SELECT distinct voter_id FROM live_theme_allocations WHERE session_id = #{session_id} AND table_id = #{table_id} ORDER BY voter_id ASC|)
  end

end

