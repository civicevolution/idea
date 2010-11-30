class InitiativeRestriction < ActiveRecord::Base
  
  def self.allow_action(initiative_id, action, member)
    messages = []
    restrictions = InitiativeRestriction.find_all_by_initiative_id_and_action(initiative_id, action)
    if restrictions.size == 0
      return true, 'no restrictions found'
    else
      #logger.debug "There are #{restrictions.size} tests"
      allowed = nil
      restrictions = restrictions.sort {|a,b| a.mandatory == true ? -1 : 1   }
      restrictions.each_index do |i|
        ir = restrictions[i]
        allowed = false if !ir.mandatory # if the test is not mandatory, then assume false until a test sets it true
        #logger.debug "Please test the restriction: #{ir.restriction} with arg: #{ir.arg}"
        case ir.restriction
          when 'match_email_domain'
            #logger.debug "check match_email_domain #{ir.arg} against user email: #{member.email}"
            if member.email.strip.match( Regexp.new ir.arg + '$', Regexp::IGNORECASE )
              allowed = true if !ir.mandatory
            else
              allowed = false if ir.mandatory
              messages.push "your email did not match the required domain of #{ir.arg}"
            end
          
          when 'belong_to_initiative'
            #logger.debug "check belong_to_initiative #{ir.arg} against member's: #{member.id} initiatives: "
            im = InitiativeMembers.find_by_initiative_id_and_member_id(initiative_id, member.id)
            if !im.nil?
              allowed = true if !ir.mandatory
            else
              allowed = false if ir.mandatory
              messages.push "you do not belong to this group: #{ir.arg}"
            end
            
          when 'confirmed'
            if member.confirmed
              allowed = true if !ir.mandatory
            else
              allowed = false if ir.mandatory
              messages.push "you need to be a confirmed member"
            end
            
        end # end case ir.restriction
        #logger.debug "End of test, allowed: #{allowed},  ir: #{ir.inspect}"
        # passing a mandatory test doesn't make it allowed, just means it isn't NOT allowed
        # allowed is only set to false if the test is mandatory and the test is failed
        return false, 'Note: ' + messages.join(' and ') if allowed == false && ir.mandatory
        
        #logger.debug "next return check"
        # only a non-mandatory test can make it allowed
        # allowed is only set to true if there are no more mandatory tests
        return true, 'no restriction' if allowed == true
        
      end # end each restrictions each loop
      # if no non-mandatory test set false to true, then not allowed 
      return false, 'Note: ' + messages.join(' and ') if allowed == false
      # return true if no non-mandatory restrictions were processed and all mandatory tests were passed
      return true, 'no restriction'
    end # end if/else restrictions size == 0
  end

  
end
