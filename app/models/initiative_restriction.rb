class InitiativeRestriction < ActiveRecord::Base

  def self.allow_actionX(initiative_id, action, member)
    # the first argument is the initiative_id if it is an integer
    # otherwise it is a hash such as :team_id=>, :question_id=>, or :answer_id=>
    # Get the initiative and team id
    if initiative_id.class.to_s == 'Hash'
      arg_hash = initiative_id
      case
        when arg_hash[:parent_type] == 1 # this is a question comment
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t left join questions q ON t.id = q.team_id WHERE q.id = #{arg_hash[:parent_id]}")
        when arg_hash[:parent_type] == 13 # this is a talking point comment
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q, talking_points tp WHERE tp.id = #{arg_hash[:parent_id]} AND t.id = q.team_id AND tp.question_id = q.id")
        when arg_hash[:parent_type] == 3 # this is a comment comment
          # I have to look at the parent
          com = Comment.find(arg_hash[:parent_id])
          if com.parent_type == 1 # the parent is a question
            rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, q.team_id FROM teams t, questions q WHERE q.id = #{com.parent_id} AND t.id = q.team_id")
          elsif com.parent_type == 3 # the parent is a comment whose parent could be a comment or a talking point
            par_com = Comment.find(com.parent_id)
            case par_com.parent_type
              when 1
                rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, q.team_id FROM teams t, questions q WHERE q.id = #{par_com.parent_id} AND q.team_id = t.id")
              when 13
                rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, q.team_id FROM teams t, questions q, talking_points tp WHERE tp.id = #{par_com.parent_id} AND tp.question_id = q.id AND q.team_id = t.id")
            end
                
          elsif com.parent_type == 13 # the parent is a talking_point
            rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, q.team_id FROM teams t, questions q, talking_points tp WHERE tp.id = #{com.parent_id} AND tp.question_id = q.id AND q.team_id = t.id")
          end
        when arg_hash.key?(:question_id) # this is a question
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q WHERE t.id = q.team_id AND q.id = #{arg_hash[:question_id]}")
        when arg_hash.key?(:talking_point_id) # this is a talking_point
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, team_id FROM teams t, questions q, talking_points tp WHERE t.id = q.team_id AND q.id = tp.question_id AND tp.id = #{arg_hash[:talking_point_id]}")
        when arg_hash.key?(:team_id)
          rec = ActiveRecord::Base.connection.select_one("SELECT initiative_id, id AS team_id FROM teams t WHERE t.id = #{arg_hash[:team_id]}")
      end
      initiative_id = rec['initiative_id'].to_i
      team_id = rec['team_id'].to_i
    end

    
    logger.debug "InitiativeRestrictions initiative_id #{initiative_id}, action: #{action}, for member: #{member.inspect}"
    if initiative_id.nil?
      logger.debug 'No initiative_id was specified'
      return false, 'No initiative_id was specified', team_id
    end
    
    #irs = YAML.load_file("#{Rails.root}/config/initiative_restrictions.yaml")
    irs = INITIATIVE_RESTRICTIONS
    
    action_rules = irs["init_#{initiative_id}"]['action_rules'][action]

    if action_rules.nil?
      return true, 'no restrictions found', team_id
    end
      
    act = action_rules['act']

    # first process the mandatory rules, I must pass all of the mandatory rules
    mandatory_rules = action_rules['mandatory']
    if !mandatory_rules.nil?
      mandatory_rules.each do |rule| 
        pass,message = process_rule(arg_hash, initiative_id, team_id, member, rule)
        if pass == false
          return false, message.sub('$act',act), team_id 
        end
      end
    end

    # then process the pass_one rules until one succeeds
    pass_one_rules = action_rules['pass_one']
    messages = []
    if !pass_one_rules.nil?
      pass_one_rules.each do |rule| 
        pass,message = process_rule(arg_hash, initiative_id, team_id, member, rule)
        if pass == true
          return true, 'no restriction', team_id 
        else
          messages.push message.sub('$act',act)
        end
      end
      return false, messages.join(' - or - '), team_id
    end
    
    return true, 'no restriction', team_id 
  end

protected

  def self.process_rule(arg_hash, initiative_id, team_id, member, rule)
    #irs = YAML.load_file("#{Rails.root}/config/initiative_restrictions.yaml")
    irs = INITIATIVE_RESTRICTIONS
    
    # read the definition from rule_definitions
    rule_name = rule.match(/\$(\w+)/)[1]
    rule_args = rule.match(/\(([^\)]*)\)/)
    rule_args = rule_args[1].split(',') if rule_args
    rule = irs["init_#{initiative_id}"]['rule_definitions'][rule_name]

    logger.debug "Please test the restriction: #{rule['restriction']}"
    
    case rule['restriction']
      when 'match_email_domain'
        #logger.debug "check match_email_domain #{ir.arg} against user email: #{member.email}"
        pass = false
        rule_args.each do |domain|
          if member.email.strip.match( Regexp.new domain.strip + '$', Regexp::IGNORECASE )
            pass = true
            break
          end
        end
        if pass == false
          message = rule['message']
        end
      
      when 'belong_to_initiative'
        #logger.debug "check belong_to_initiative #{ir.arg} against member's: #{member.id} initiatives: "
        im = InitiativeMembers.find_by_initiative_id_and_member_id(initiative_id, member.id)
        if !im.nil?
          pass = true
        else
          pass = false
          message = rule['message']
        end
        
      when 'confirmed_member'
        if member.confirmed
          pass = true
        else
          pass = false
          message = rule['message']
        end
        
      when 'team_org'
        org_id = ActiveRecord::Base.connection.select_value("SELECT org_id FROM teams WHERE id = #{team_id}")
        if member.id == org_id.to_i
          pass = true
        else
          pass = false
          message = rule['message']
        end

      when 'minimum_level'
        level = ActiveRecord::Base.connection.select_value("SELECT level FROM participant_stats WHERE member_id = #{member.id} AND team_id = #{team_id}")
        if !level.nil? && level.to_i >= rule_args[0].to_i
          pass = true
        else
          pass = false
          message = rule['message'].sub('$level',rule_args[0].to_s)
        end
      
      when 'talking_point_author'
        # Am I the current author
        if member.id == arg_hash[:tp_member_id]
          pass = true
        elsif TalkingPointVersion.where(:member_id => member.id, :talking_point_id => arg_hash[:talking_point_id]).exists?
          # if not, am I a previous author of an earlier version?
          pass = true
        else
          # Not author or a previous author
          pass = false
          message = rule['message']
        end
        
      else
        raise "We cannot process initiative_restriction: #{rule['restriction']}"
    end # end case rule.restriction
    return pass, message
  end

end
