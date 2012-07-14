class PreliminaryParticipantActivity < ActiveRecord::Base
  serialize :flash_params
  
  before_create :trim_email
  
  attr_accessible :email, :flash_params, :init_id
  
  def self.process_all( member, init_id, host, destroy_records = true )
    
    # process the participant activities that I logged before they signed in 
    ppas = PreliminaryParticipantActivity.select('id, email, flash_params').where(:email => member.email, :init_id => init_id ).order(:id)
    ppas.each do |ppa|
    	case
    		when ppa.flash_params[:action] == 'rate_talking_point'
    		  begin
      			TalkingPointAcceptableRating.record( member, ppa.flash_params[:talking_point_id], ppa.flash_params[:rating] )
          rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end
    		when ppa.flash_params[:action] == 'prefer_talking_point'
    		  begin
      			tpp = TalkingPointPreference.find_or_create_by_member_id_and_talking_point_id(member.id, ppa.flash_params[:talking_point_id])
      			ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, tpp.errors, host).deliver unless tpp.errors.empty?
    			rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end
    		when ppa.flash_params[:action] == 'create_talking_point_comment'
    		  begin
      			comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => 13, :parent_id => ppa.flash_params[:talking_point_id] )
      			ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, comment.errors, host).deliver unless comment.errors.empty?
      		rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end	
    		#when ppa.flash_params[:action].match(/create_comment_comment/)
    		#  begin
    		#    par_com = Comment.find(ppa.flash_params[:comment_id])
        #    if par_com.parent_type == 1 # if parent is a comment under a question, then make this a child to that comment
        #      comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => 3,  :parent_id => ppa.flash_params[:comment_id] )
        #    else # otherwise, make this a sibling to the parent, a child to the parent's parent
        #      comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => par_com.parent_type,  :parent_id => par_com.parent_id )
        #    end
      	#		ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, comment.errors, host).deliver unless comment.errors.empty?
      	#	rescue Exception => e
        #    ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
        #  end	
    		when ppa.flash_params[:action] == "add_talking_point" 
    		  begin
      			talking_point = TalkingPoint.create(:member=> member, :text => ppa.flash_params[:text], :question_id => ppa.flash_params[:question_id] )
      			ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, talking_point.errors, host).deliver unless talking_point.errors.empty?
      		rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end
    		when ppa.flash_params[:action] == 'add_endorsement'
    		  begin
    		    endorsement = Endorsement.find_by_member_id_and_team_id(member.id,ppa.flash_params[:team_id])
            endorsement = Endorsement.new :member_id => member.id, :team_id => ppa.flash_params[:team_id] if endorsement.nil?
            endorsement.member = member
            endorsement.text = ppa.flash_params[:text]
            endorsement.save
            ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, endorsement.errors, host).deliver unless endorsement.errors.empty?
          rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end  
        when ppa.flash_params[:action] == 'vote_save'
    		  begin
    		    votes = {}
            ppa.flash_params.each_pair do |key,value|
              if key.match(/^vote_\d+/) && value.to_i > 0
                votes[ key.match(/\d+/)[0].to_i] = value.to_i
              end
            end

            saved, err_msgs = ProposalVote.save_votes(init_id, member.id, votes)

            ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, err_msgs, host).deliver unless err_msgs.nil? || err_msgs.empty?
          rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end  
    		when ppa.flash_params[:action].match(/update_worksheet_ratings/)
    		  begin
      		  unrecorded_talking_point_preferences = Question.update_worksheet_ratings( member, ppa.flash_params )
      		rescue Exception => e
      		  ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end
    		when ppa.flash_params[:action] == 'submit_proposal_idea'
    		  begin
      		  proposal_idea = ProposalIdea.new ppa.flash_params[:proposal_idea]
            proposal_idea.member = member
            if proposal_idea.save
              ProposalMailer.delay.submit_receipt(member, proposal_idea, ppa.flash_params[:_app_name] )
              ProposalMailer.delay.review_request(member, proposal_idea, host, ppa.flash_params[:_app_name] )
            else
              # what do I do if there is an error saving the proposal?
              ClientDebugMailer.preliminary_activity_failed(ppa.email, ppa.flash_params, proposal_idea.errors, host).deliver
            end
          rescue Exception => e
            ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, e.message, e.backtrace, host).deliver
          end
        else
          ClientDebugMailer.preliminary_activity_exception(ppa.email, ppa.flash_params, "Don't know how to process this", "Please investigate", host).deliver
    	end
    	ppa.destroy unless !destroy_records
    end
    nil
  end
  
  
  def trim_email
    self.email = self.email.strip.downcase unless self.email.nil?
  end
end
