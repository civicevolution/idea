class ProposalVote < ActiveRecord::Base
  
  def self.save_votes(init_id, member_id, votes)
    ProposalVote.delete_all(:initiative_id => init_id, :member_id => member_id)
    votes.each_pair do |team_id, points|
      ProposalVote.create( :initiative_id=> init_id, :member_id => member_id, :team_id => team_id, :points => points )
    end
    
  end
  
end
