class ProposalVote < ActiveRecord::Base
  
  attr_accessible :initiative_id, :member_id, :team_id, :points
  
  def self.save_votes(init_id, member_id, votes)
    # check that the votes are allowed limits
    vote_sum = 0
    vote_over = false
    votes.each_value do |points|
      vote_over = true if points > 40
      vote_sum += points
    end
    
    err_msgs = {}
    if vote_sum > 100
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You cannot allocate more than $100"
    end
    if vote_over
      err_msgs[:full_messages] = [] if err_msgs.empty?
      err_msgs[:full_messages].push "You cannot allocate more than $40 to any single idea"
    end
    
    if err_msgs.empty?
      ProposalVote.delete_all(:initiative_id => init_id, :member_id => member_id)
      votes.each_pair do |team_id, points|
        ProposalVote.create( :initiative_id=> init_id, :member_id => member_id, :team_id => team_id, :points => points )
      end
      return true, nil
    else
      return false, err_msgs
    end
    
  end
  
end
