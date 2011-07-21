class Team < ActiveRecord::Base

  has_many :team_registrations
  has_many :members, :through => :team_registrations
  
  has_many :questions
  
  
  
  #has_many :items
  #has_many :pages, :through => :items
  #has_many :questions, :through => :items
  #has_many :answers, :through => :items
  #has_many :comments, :through => :items
  #has_many :ratings, :through => :items
  #has_many :thumbs_ratings, :through => :items
  #has_many :lists, :through => :items  

  attr_accessor :member_id
  attr_accessor :last_visit_ts
  
  #validate_on_update :check_team_edit_access
  validate :check_team_edit_access, :on=>:update
  
  def get_talking_point_ratings(member_id)
    self.member_id = member_id
    self.last_visit_ts = Time.local(2012,2,23)
    
    question_ids = self.questions.map{|q| q.id}
    talking_point_ids = []
    self.questions.each{|q| q.top_talking_points.each{ |tp| talking_point_ids << tp.id }}
    tpp = TalkingPointPreference.sums(talking_point_ids)
    tpr = TalkingPointAcceptableRating.sums(talking_point_ids)
    my_preferences = TalkingPointPreference.my_votes(talking_point_ids, self.member_id)
    my_ratings = TalkingPointAcceptableRating.my_votes(talking_point_ids, self.member_id)

    question_coms = ActiveRecord::Base.connection.select_all(
    %Q|select ques_id,
    (select count(id) from comments where parent_type=1 and parent_id = ques_id) AS coms,
    (SELECT count(id) from comments where parent_type=1 and parent_id = ques_id AND created_at > '#{last_visit_ts}') AS new_coms,
    (select count(id) from talking_points where question_id = ques_id) AS num_talking_points,
    (SELECT count(id) from talking_points where question_id = ques_id AND created_at > '#{last_visit_ts}') AS num_new_talking_points
    FROM ( VALUES #{ question_ids.map{ |id| "(#{id})" }.join(',')	 } ) AS q (ques_id)|)
    
    talking_point_coms = ActiveRecord::Base.connection.select_all(
    %Q|select talking_point_id,
    (select count(id) from comments where parent_type=13 and parent_id = talking_point_id) AS coms,
    (SELECT count(id) from comments where parent_type=13 and parent_id = talking_point_id AND created_at > '#{last_visit_ts}') AS new_coms
    FROM ( VALUES #{ talking_point_ids.map{ |id| "(#{id})" }.join(',') } ) AS t (talking_point_id)|)

    self.questions.each do |q| 
      qcom = question_coms.detect{|qc| qc['ques_id'].to_i == q.id}
      if !qcom.nil?
        q.coms = qcom['coms'].to_i
        q.new_coms = qcom['new_coms'].to_i
        q.num_talking_points = qcom['num_talking_points'].to_i
        q.num_new_talking_points = qcom['num_new_talking_points'].to_i
      end

      q.top_talking_points.each do |tp| 
        pref = tpp.detect{|p| p.talking_point_id == tp.id}
        tp.preference_votes = pref.count.to_i unless pref.nil? 
        
        tp.rating_votes = [0,0,0,0,0]
        tpr.select{|rec| rec.talking_point_id == tp.id}.each do |r|
          tp.rating_votes[r.rating-1] = r.count
        end
        
        my_pref = my_preferences.detect{|p| p.talking_point_id == tp.id}
        tp.my_preference = my_pref.nil? ? false : true 
        
        my_rating = my_ratings.detect{|r| r.talking_point_id == tp.id}
        tp.my_rating = my_rating.rating unless my_rating.nil?

        tpcom = talking_point_coms.detect{|tpc| tpc['talking_point_id'].to_i == tp.id}
        if !tpcom.nil?
          tp.coms = tpcom['coms'].to_i
          tp.new_coms = tpcom['new_coms'].to_i
        else
          tp.coms = 0
          tp.new_coms = 0
        end
      end

    end
    
    
    
    true
  end
  
  def check_team_edit_access
    logger.debug "validate_on_update check_team_edit_access"
    
    # I will need to check if the iteam can still be edited
    
    # are you a still a team member
    #is_team_member = ! (TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.id).nil?)
    #logger.debug "ist_team_member: #{is_team_member}"
    # return as ok if user is a team member
    return if member_id == self.org_id || member_id == 1
    
    errors.add_to_base("You must be a member of this team to edit it.")

  end  
  
  
  
  def o_type
    4 #type for Teams
  end
  def type_text
    'team' #type for Answers
  end
  def text
    self.title
  end
  
  def bs_ideas_with_ratings(memberId)
    BsIdeaRating.find_by_sql([ %q|SELECT bsi.id, 
    AVG(rating) AS average, 
    COUNT(rating) AS count, 
    (SELECT rating FROM bs_idea_ratings WHERE member_id = ? AND idea_id = bsi.id) AS my_vote,
    bsi.question_id AS q_id, bsi.member_id, bsi.text, bsi.created_at, bsi.updated_at
    FROM bs_ideas bsi LEFT OUTER JOIN bs_idea_ratings bsir ON bsi.id = bsir.idea_id
    WHERE team_id = ?
    GROUP BY bsi.id, bsi.question_id, bsi.member_id,bsi.text, bsi.created_at, bsi.updated_at;|, memberId, self.id ]
    )
  end

  def answers_with_ratings(memberId)
    AnswerRating.find_by_sql([ %q|SELECT a.id, 
      AVG(rating) AS average, 
      COUNT(rating) AS count, 
      (SELECT rating FROM answer_ratings WHERE member_id = ? AND answer_id = a.id) AS my_vote,
      a.question_id AS q_id, a.member_id, a.text, a.ver, a.created_at, a.updated_at, i.id AS item_id
      FROM answers a LEFT JOIN items AS i ON i.o_id = a.id AND i.o_type = 2 LEFT OUTER JOIN answer_ratings ar ON a.id = ar.answer_id
      WHERE a.team_id = ?
      GROUP BY a.id, a.question_id, a.member_id,a.text, a.ver, a.created_at, a.updated_at, i.id|, memberId, self.id ]
    )
  end

  def answers_with_ratings_i(memberId)
    Answer.find_by_sql([ %q|SELECT a.id, 
      AVG(rating) AS average, 
      COUNT(rating) AS count, 
      (SELECT rating FROM answer_ratings WHERE member_id = ? AND answer_id = a.id) AS my_vote,
      a.question_id AS q_id, a.member_id, a.text, a.ver, a.created_at, a.updated_at, i.id AS item_id
      FROM answers a LEFT JOIN items AS i ON i.o_id = a.id AND i.o_type = 2 LEFT OUTER JOIN answer_ratings ar ON a.id = ar.answer_id
      WHERE a.team_id = ?
      GROUP BY a.id, a.question_id, a.member_id,a.text, a.ver, a.created_at, a.updated_at, i.id|, memberId, self.id ]
    )
  end

  def comments_with_ratings(memberId)
    Comment.find_by_sql([ %q|SELECT c.id, 
      SUM(up) AS up,
      SUM(down) AS down,
      (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = ? AND comment_id = c.id) AS my_vote,
      c.member_id, c.text, c.anonymous, c.created_at, c.updated_at
      FROM comments c LEFT OUTER JOIN com_ratings cr ON c.id = cr.comment_id
      WHERE team_id = ?
      GROUP BY c.id, c.member_id, c.text, c.anonymous, c.created_at, c.updated_at|, memberId, self.id ]
    )
  end

  def public_authors(author_ids)
    Member.all(:conditions=> {:id => author_ids })
    #pub_authors = Member.all(
    #  :select => 'id, first_name, last_name, ape_code, pic_id',
    #  :conditions=> {:id => authorIds }
    #)
    #pub_authors.collect { |m| {:id=> m.id, :first_name=>m.first_name, :last_name=>m.last_name, :ape_code=> m.ape_code, :pic_id => m.pic_id,:member => 'f' }  }
  end
    
  def stats
    if @stats.nil?
      @stats = Team.find_by_sql([ %q|SELECT (SELECT COUNT(*) FROM team_registrations WHERE team_id = ?) AS members,
        (SELECT COUNT(*) FROM comments WHERE team_id = ?) AS comments,
        (SELECT COUNT(*) FROM bs_ideas WHERE team_id = ?) AS bs_ideas,
        (SELECT COUNT(*) FROM answers WHERE team_id = ?) AS answers|, self.id, self.id, self.id, self.id ]
      )[0]
    end
    @stats
    
  end  
    
  def self.teams_with_stats(initiative_id)
    Team.find_by_sql([ %q|SELECT id, org_id, title, solution_statement, status, min_members, max_members, signup_mode, launched,
      (SELECT COUNT(*) FROM team_registrations WHERE team_id = t.id) AS members
      FROM teams t 
      WHERE initiative_id = ?|, initiative_id ]
    )
  end
  
  def resources
    Resource.find(:all, 
      :select => 'r.*', 
      :conditions => ['i.team_id = ? AND i.o_type = 3', self.id],
      :joins => 'as r inner join items as i on i.o_id = r.comment_id' 
    )
  end
  
  def list_items
    ListItem.find(:all, 
      :select => 'li.*', 
      :conditions => ['i.team_id = ? AND i.o_type = 7', self.id],
      :joins => 'as li inner join items as i on i.o_id = li.list_id',
      :order => '"order"' 
    )
  end
  
  def last_visit(member_id)
    Activity.maximum(:created_at, :conditions => ['member_id = ? AND team_id = ? AND action = \'team index\'', member_id, self.id]) || Time.now
  end
  
  def public_disc_data(memberId)
    # get pub discussion header items
    pub_disc_items = Item.all(:conditions => ['team_id = ? AND o_type = 11', self.id])
    return [Item.new], [Comment.new], [Resource.new], [Member.new] if pub_disc_items.size() == 0
    # create an array
    pub_disc_ids = pub_disc_items.collect {|pdi| pdi.id }
    # get pub discussion descendents
    pub_disc_descendent_items = Item.all(:conditions => ['team_id = ? and o_type = 3 AND ARRAY[?] && ancestors', self.id, pub_disc_ids ])
    com_ids = pub_disc_descendent_items.collect {|pddi| pddi.o_id }
    #comments = Comment.find_all_by_id(com_ids)
    comments_with_ratings = Comment.all(
      :select=> %Q|c.id, 
        SUM(up) AS up,
        SUM(down) AS down,
        (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = #{memberId} AND comment_id = c.id) AS my_vote,
        c.member_id, c.text, c.anonymous, c.created_at, c.updated_at|,
      :joins=> 'as c LEFT OUTER JOIN com_ratings cr ON c.id = cr.comment_id',
      :conditions=> {'c.id' => com_ids},
      :group=> 'c.id, c.member_id, c.text, c.anonymous, c.created_at, c.updated_at'
    )
    resources = Resource.find_all_by_comment_id(com_ids)
    author_ids = comments.collect {|c| c.member_id }.uniq
    #pub_authors = Member.find_all_by_id(author_ids, :select=>'id,first_name, last_name, pic_id, ape_code')
    #pub_authors = pub_authors.collect { |m| {:id=> m.id, :first_name=>m.first_name, :last_name=>m.last_name, :ape_code=> m.ape_code, :pic_id => m.pic_id,:member => 'f' }  }
    pub_authors = Member.all(:conditions=> {:id => author_ids })
    return pub_disc_items.concat( pub_disc_descendent_items ), comments_with_ratings, resources, pub_authors
  end
  
  
  def create_team_idea_page()
    logger.debug "create_team_idea_page for id: #{self.id}, \"#{self.title}\""
    yml = YAML.load_file "#{Rails.root}/config/idea_page_template.yaml"
  
    if !self.launched
      member = Member.find(self.org_id)
      team_item = Item.find_by_o_id_and_o_type(self.id, 4)
      yml.each_pair { |key, value|
        logger.debug "#{key}"
        rec = value
        #logger.debug "#{rec['question']}"
        page = Page.new :page_title=>rec['page_title'], :chat_title=>rec['chat_title'], :nav_title=>rec['nav_title'], :par_id=>team_item.id
        page.save
        # set the order according to yaml
        item = Item.find(page.item_id)
        item.order = rec['order']
        item.save
    
        # if there is a question, add it
        if !rec['question'].nil?
          logger.debug "add_a_question for page: #{page.nav_title}"
          # create a quesstion record
          question = Question.new :member_id=>self.org_id, :text=>rec['question'], :par_id=> page.item_id, :target_id=>0, :target_type=>0, :team_id=>self.id,
            :idea_criteria=>rec['idea_criteria'], :answer_criteria=>rec['answer_criteria'], :num_answers=>rec['num_answers'], :default_answer_id=>rec['default_answer_id']
          question.save   
                                                                                                                            
        end

      }

      self.launched = true
      self.save

      #notify the submittor when the idea is approved
      #logger.debug '####################### member has been defaulted to admin'
      #member = Member.find(1)
      #host = self.initiative_id == 1 ? 'cgg.civicevolution.org' : '2029.civicevolution.org'
      #ProposalMailer.deliver_idea_page_available(member, self, host )
      
    end
  end
  
  def create_team_workspace(tr)
    logger.debug "create_team_workspace for id: #{self.id}, \"#{self.title}\""
    yml = YAML.load_file 'config/proposal_template.yaml'
  
    if !self.launched
      member = Member.find(self.org_id)
      team_item = Item.find_by_o_id_and_o_type(self.id, 4)
      yml.each_pair { |key, value|
        logger.debug "#{key}"
        rec = value
        #logger.debug "#{rec['question']}"
        page = Page.new :page_title=>rec['page_title'], :chat_title=>rec['chat_title'], :nav_title=>rec['nav_title'], :par_id=>team_item.id
        page.save
        # set the order according to yaml
        item = Item.find(page.item_id)
        item.order = rec['order']
        item.save
    
        # if there is a question, add it
        if !rec['question'].nil?
          logger.debug "add_a_question for page: #{page.nav_title}"
          # create a quesstion record
          question = Question.new :member_id=>self.org_id, :text=>rec['question'], :par_id=> page.item_id, :target_id=>0, :target_type=>0, 
            :idea_criteria=>rec['idea_criteria'], :answer_criteria=>rec['answer_criteria'], :num_answers=>rec['num_answers']
          question.save   
          
          # create a public discussion item for the question
          
          pub_disc_item = Item.new( :team_id=>self.id, :o_id=> question.id, :o_type=>11, :par_id=>question.item_id, :order=>0, :sib_id=>0, 
            :ancestors=> '{' + ((Item.find(question.item_id).ancestors.split(',').collect! {|n| n.to_i}) + [ question.item_id ]).join(',') + '}', :target_id=>0, :target_type=>0 )
          pub_disc_item.save        
                                                                                                                  
        end

        if !rec['team_info'].nil?
          team_info_item = Item.new :team_id=>self.id, :o_id=> self.id, :o_type=>10, :par_id=>page.item_id, :order=>0, :sib_id=>0, 
             :ancestors=>"{0,#{team_item.id},#{page.item_id}}", :target_id=>0, :target_type=>0
          team_info_item.save        
        end
      }
      
      # I need to give it a member_id for a member so I can update the record with launched, then restore to whatever it was
      member_id = self.member_id      
      self.member_id = TeamRegistration.find_by_team_id(self.id).member_id
      self.launched = true
      self.save
      self.member_id = member_id
      
      #notify the team - for now just the author
      members = Member.all( 
          :select => 'first_name, last_name, email', 
          :conditions => ['m.id = tr.member_id AND tr.team_id = ?', self.id],
          :joins => 'as m inner join team_registrations as tr on m.id = tr.member_id' 
        )
        
      members.each do |member|
        ProposalMailer.delay.team_workspace_available(member, self, tr.host )
      end
      
    end
  end

  def create_custom_team_workspace(config_file_path,tr)
    logger.debug "create_custom_team_workspace for id: #{self.id}, \"#{self.title}\" with config file: #{config_file_path}"
    yml = YAML.load_file config_file_path
  
    if !self.launched
      member = Member.find(self.org_id)
      team_item = Item.find_by_o_id_and_o_type(self.id, 4)
      yml.each_pair { |key, value|
        logger.debug "#{key}"
        rec = value
        #logger.debug "#{rec['question']}"
        page = Page.new :page_title=>rec['page_title'], :chat_title=>rec['chat_title'], :nav_title=>rec['nav_title'], :par_id=>team_item.id
        page.save
        # set the order according to yaml
        item = Item.find(page.item_id)
        item.order = rec['order']
        item.save
    
        # if there is a question, add it
        if !rec['question'].nil?
          logger.debug "add_a_question for page: #{page.nav_title}"
          # create a quesstion record
          question = Question.new :member_id=>self.org_id, :text=>rec['question'], :par_id=> page.item_id, :target_id=>0, :target_type=>0, 
            :idea_criteria=>rec['idea_criteria'], :answer_criteria=>rec['answer_criteria'], :num_answers=>rec['num_answers']
          question.save   
          
          # create a public discussion item for the question
          
          pub_disc_item = Item.new( :team_id=>self.id, :o_id=> question.id, :o_type=>11, :par_id=>question.item_id, :order=>0, :sib_id=>0, 
            :ancestors=> '{' + ((Item.find(question.item_id).ancestors.split(',').collect! {|n| n.to_i}) + [ question.item_id ]).join(',') + '}', :target_id=>0, :target_type=>0 )
          pub_disc_item.save        
                                                                                                                  
        end

        if !rec['team_info'].nil?
          team_info_item = Item.new :team_id=>self.id, :o_id=> self.id, :o_type=>10, :par_id=>page.item_id, :order=>0, :sib_id=>0, 
             :ancestors=>"{0,#{team_item.id},#{page.item_id}}", :target_id=>0, :target_type=>0
          team_info_item.save        
        end
      }
      self.launched = true
      self.save
      
      #notify the team - for now just the author
      members = Member.all( 
          :select => 'first_name, last_name, email', 
          :conditions => ['m.id = tr.member_id AND tr.team_id = ?', self.id],
          :joins => 'as m inner join team_registrations as tr on m.id = tr.member_id' 
        )
        
      members.each do |member|
        ProposalMailer.delay.team_workspace_available(member, self, tr.host )
      end
      
    end
  end
  
  def self.gen_report(initiative_id)
    # id, title, launched, # members, #coms, # ideas, # answers, # chats,     
    #Team.all(
    #  :select => 'id, title, launched', 
    #  :conditions => ['initiative_id = ?', initiative_id]
    #)
    
    Team.find_by_sql([ %q|SELECT id, org_id, title, solution_statement, status, min_members, max_members, signup_mode, launched,
      (SELECT count(member_id) from (SELECT member_id FROM comments WHERE team_id = t.id
      UNION
      SELECT member_id FROM bs_ideas WHERE team_id = t.id
      UNION
      SELECT org_id as member_id FROM teams WHERE id = t.id
      UNION 
      SELECT member_id from item_diffs where o_type = 2 and o_id in (select id from answers where team_id = t.id)) as participants) AS participants,
      (SELECT COUNT(*) FROM comments WHERE team_id = t.id) AS comments,
      (SELECT COUNT(*) FROM bs_ideas WHERE team_id = t.id) AS bs_ideas,
      (SELECT COUNT(*) FROM answers WHERE team_id = t.id) AS answers,
      (SELECT COUNT(*) FROM endorsements WHERE team_id = t.id) AS endorsements
      FROM teams t 
      WHERE initiative_id = ?
      ORDER BY launched DESC, title|, initiative_id ]
    )
    
  end  
  
  def self.delete_team(team_id, delete_code)
    
    # check that the team.join_code is delete_NNNN
    
    team = Team.find(team_id)
    
    #logger.debug "team.join_code: #{team.join_code}, team.join_code.match(/^delete_\d{5}$/) : #{team.join_code.match(/^delete_\d{5}$/) }"
    #logger.debug "delete_code: #{delete_code}"
    if !team.join_code.match(/^delete_\d{5}$/) || team.join_code != delete_code
      raise TeamAccessDeniedError, "You cannot delete this team"
      #raise TeamAccessDeniedError, "You cannot delete this team team.join_code: #{team.join_code}, team.join_code.match(/^delete_\d{5}$/) : #{team.join_code.match(/^delete_\d{5}$/) }, delete_code: #{delete_code}"
      return
    end 
    
    Team.connection.select_all("DELETE FROM com_ratings WHERE comment_id IN (SELECT id FROM comments WHERE team_id = #{team_id})")
    Team.connection.select_all("DELETE FROM resources WHERE comment_id IN (SELECT id FROM comments WHERE team_id = #{team_id})")
    Team.connection.select_all("DELETE FROM comments WHERE team_id = #{team_id}")

    Team.connection.select_all("DELETE FROM answer_ratings WHERE answer_id IN (SELECT id FROM answers WHERE team_id = #{team_id})")
    Team.connection.select_all("DELETE FROM answers WHERE team_id = #{team_id}")

    Team.connection.select_all("DELETE FROM bs_idea_ratings WHERE idea_id IN (SELECT id FROM bs_ideas WHERE question_id in (select o_id from items where team_id = #{team_id} and o_type = 1))")
    Team.connection.select_all("DELETE FROM bs_ideas WHERE question_id in (select o_id from items where team_id = #{team_id} and o_type = 1)")
    Team.connection.select_all("DELETE FROM questions WHERE id in (select o_id from items where team_id = #{team_id} and o_type = 1)")

    Team.connection.select_all("DELETE FROM page_chat_messages WHERE page_id in (select o_id from items where team_id = #{team_id} and o_type = 9)")
    Team.connection.select_all("DELETE FROM pages WHERE id in (select o_id from items where team_id = #{team_id} and o_type = 9)")

    Team.connection.select_all("DELETE FROM item_versions WHERE item_id IN (SELECT id FROM items WHERE team_id = #{team_id})")
    Team.connection.select_all("DELETE FROM item_diffs WHERE id IN (SELECT id.id FROM item_diffs id, items i WHERE i.team_id = #{team_id} AND id.o_id = i.o_id AND id.o_type = i.o_type)")
    Team.connection.select_all("DELETE FROM item_locks WHERE id IN (SELECT il.id FROM item_locks il, items i WHERE i.team_id = #{team_id} AND il.o_id = i.o_id AND il.o_type = i.o_type)")
    Team.connection.select_all("DELETE FROM items WHERE team_id = #{team_id}")

    Team.connection.select_all("DELETE FROM team_registrations WHERE team_id = #{team_id}")

    Team.connection.select_all("DELETE FROM teams WHERE id = #{team_id}")
  end
  
end
