class InitiativeRestriction < ActiveRecord::Base

  def self.allow_actionX(initiative_id, action, member)
    # the first argument is the initiative_id if it is an integer
    # otherwise it is a hash such as :team_id=>, :question_id=>, or :answer_id=>
    if initiative_id.class.to_s == 'Hash'
      case
        when initiative_id[:parent_type] == 1 # this is a question comment
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t left join questions q ON t.id = q.team_id WHERE q.id = #{initiative_id[:parent_id]}")
        when initiative_id[:parent_type] == 13 # this is a talking point comment
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q, talking_points tp WHERE tp.id = #{initiative_id[:parent_id]} AND t.id = q.team_id AND tp.question_id = q.id")
        when initiative_id.key?(:question_id) # this is a question
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q WHERE t.id = q.team_id AND q.id = #{initiative_id[:question_id]}")
        when initiative_id.key?(:talking_point_id) # this is a talking_point
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q, talking_points tp WHERE t.id = q.team_id AND q.id = tp.question_id AND tp.id = #{initiative_id[:talking_point_id]}")

        #when initiative_id.key?(:team_id)
        #  initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = #{initiative_id.values[0].to_i}" )
        #when initiative_id.key?(:question_id)
        #  initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM items where o_id = #{initiative_id.values[0].to_i} and o_type = 1)" )
        #when initiative_id.key?(:answer_id)
        #  initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM answers where id = #{initiative_id.values[0].to_i})" )
        #when initiative_id.key?(:comment_id)
        #  initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM comments where id = #{initiative_id.values[0].to_i})" )
        #when initiative_id.key?(:bs_idea_id)
        #  initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM bs_ideas where id = #{initiative_id.values[0].to_i})" )
      end
      initiative_id = rec['initiative_id'].to_i
      team_id = rec['team_id'].to_i
    end
    
    logger.debug "InitiativeRestrictions initiative_id #{initiative_id}, action: #{action}, for member: #{member.inspect}"
    if initiative_id.nil?
      logger.debug 'No initiative_id was specified'
      return false, 'No initiative_id was specified', team_id
    end
    messages = []
    restrictions = InitiativeRestriction.find_all_by_initiative_id_and_action(initiative_id, action)
    if restrictions.size == 0
      return true, 'no restrictions found', team_id
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
        return false, 'Note: ' + messages.join(' and '), team_id if allowed == false && ir.mandatory
        
        #logger.debug "next return check"
        # only a non-mandatory test can make it allowed
        # allowed is only set to true if there are no more mandatory tests
        return true, 'no restriction', team_id if allowed == true
        
      end # end each restrictions each loop
      # if no non-mandatory test set false to true, then not allowed 
      return false, 'Note: ' + messages.join(' and '), team_id if allowed == false
      # return true if no non-mandatory restrictions were processed and all mandatory tests were passed
      return true, 'no restriction', team_id
    end # end if/else restrictions size == 0
  end
  
  def self.allow_action(initiative_id, action, member)
    # the first argument is the initiative_id if it is an integer
    # otherwise it is a hash such as :team_id=>, :question_id=>, or :answer_id=>
    if initiative_id.class.to_s == 'Hash'
      case initiative_id.keys[0].to_s
        when 'team_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = #{initiative_id.values[0].to_i}" )
        when 'question_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM items where o_id = #{initiative_id.values[0].to_i} and o_type = 1)" )
        when 'answer_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM answers where id = #{initiative_id.values[0].to_i})" )
        when 'comment_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM comments where id = #{initiative_id.values[0].to_i})" )
        when 'bs_idea_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM bs_ideas where id = #{initiative_id.values[0].to_i})" )
        when 'item_id'
          initiative_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = (SElECT team_id FROM items where id = #{initiative_id.values[0].to_i})" )
      end
    end
    
    logger.debug "InitiativeRestrictions initiative_id #{initiative_id}, action: #{action}, for member: #{member.inspect}"
    if initiative_id.nil?
      logger.debug 'No initiative_id was specified'
      return false, 'No initiative_id was specified'
    end
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
