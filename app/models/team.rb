require 'differ'
class Team < ActiveRecord::Base
  include LibGetTalkingPointsRatings
  
  has_many :team_registrations
  has_many :members, :through => :team_registrations
  
  has_many :questions, :conditions => 'inactive = false', order: "order_id ASC"
  has_many :all_questions, :class_name => 'Question'
  
  has_one :organizer, :class_name => 'Member', :foreign_key => 'id', :primary_key => 'org_id'
  
  has_one :proposal_stats
  has_many :participant_stats, :class_name => 'ParticipantStats'
  
  has_many :question_ideas, class_name: 'Idea', conditions: 'role = 3', order: 'order_id asc'
  has_one :idea, class_name: 'Idea', conditions: 'role = 4'
  
  attr_accessible :initiative_id, :org_id, :title, :problem_statement, :solution_statement, :status, :min_members, :max_members, :timezone, :lang, :config_id, :public_face, :public_face_rating_threshold, :archived, :signup_mode, :join_test, :join_code, :approve_join, :send_invites, :approve_invites, :admin_groups, :country, :state, :county, :city, :com_criteria, :res_criteria, :launched

  
  attr_accessor :member
  attr_accessor :new_talking_points
  attr_accessor :new_talking_points_count
  attr_accessor :updated_talking_points_count
  attr_accessor :new_comments
  attr_accessor :new_content
  attr_accessor :host
  
  #validate_on_update :check_team_edit_access
  validate :check_team_edit_access, :on=>:update
  validates_length_of :title, :in => 12..250, :allow_blank => false
  validates_presence_of :org_id
  
  
  def check_team_edit_access
    logger.debug "validate_on_update check_team_edit_access"
    
    # I will need to check if the iteam can still be edited
    
    # are you a still a team member
    #is_team_member = ! (TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.id).nil?)
    #logger.debug "ist_team_member: #{is_team_member}"
    # return as ok if user is a team member
    return if self.member.id == self.org_id || self.member.id == 1
    
    errors.add(:base, "You must be a member of this team to edit it.")

  end  
  
  def participants
    participation_records = ActiveRecord::Base.connection.select_rows("SELECT member_id, SUM(points) FROM participation_events WHERE team_id = #{self.id} AND member_id != 10 GROUP BY member_id order by SUM(points) DESC")
    members = Member.select('id, first_name, last_name, ape_code, photo_file_name').where( :id => participation_records.map{|p|p[0]})
    
    # Now I need to get the points back into the members
    participation_records.each{ |rec| members.detect{|m| m.id == rec[0].to_i}[:points] = rec[1].to_i }
    return members
  end
  
  def stats
    #@stats || ProposalStats.find_by_team_id(self.id)
    
    if @stats.nil?
      @stats = ProposalStats.find_by_team_id(self.id)
      @stats.proposal_views += stats.proposal_views_base if @stats
      @stats.question_views += stats.question_views_base if @stats
    end
    @stats
  end  
  
  def self.proposal_stats(initiative_id)
    ProposalStats.select("title, solution_statement, ps.*").joins(" as ps JOIN teams AS t ON ps.team_id = t.id").where("t.initiative_id = ? and t.archived = false", initiative_id)
  end
  
  def proposal_data
    com_data = ActiveRecord::Base.connection.select_rows(%Q|SELECT id, question_id, parent_id, extract(epoch from created_at)
    FROM comments 
    WHERE team_id = #{self.id}
    ORDER BY question_id, parent_id|)

    idea_data = ActiveRecord::Base.connection.select_rows(%Q|SELECT id, question_id, parent_id, role, extract(epoch from updated_at)
    FROM ideas 
    WHERE team_id = #{self.id}
    ORDER BY role, question_id, parent_id|)

    rating_data = ActiveRecord::Base.connection.select_rows(%Q|SELECT idea_id, ir.member_id, rating
    FROM idea_ratings ir, ideas i
    WHERE ir.idea_id = i.id
    AND i.team_id = #{self.id}|)
    
    return com_data, idea_data, rating_data
  end
  
  def include_curated_talking_points
    # eager load the curated talking points and attach them to the questions in order as question.curated_talking_points
    #iterate through to collect the curated_ids
    tp_ids = {}  
    self.questions.each do |question|
      tp_ids[question.id] = question.curated_tp_ids.nil? ? [] : question.curated_tp_ids.split(',').collect{|id| id.to_i}  
      question.curated_talking_points_set = []
    end
    
    #Query for all curated TP
    talking_points = TalkingPoint.where(:id => tp_ids.values.flatten)

    #iterate through talking points and assign the tp to the questions in order of curated ids
    talking_points.each do |talking_point|
      begin
        self.questions.detect{|q| q.id == talking_point.question_id}.curated_talking_points_set[ tp_ids[talking_point.question_id].index(talking_point.id) ] = talking_point
      rescue
        #debugger
      end
      
    end
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
    
  def assign_new_theme_content(member,last_stat_update)
    q_ids = self.questions.map(&:id)
    q_ids = [0] if q_ids.size == 0
    
    self.new_content = {}
    self.question_ideas.each{|question| question.unrated_ideas_count = 0 }
    
    if member.id != 0
      # gets the unrated ideas
      
      unrated_ideas = ActiveRecord::Base.connection.select_rows(
        %Q|SELECT COUNT(ideas.id), ideas.question_id FROM ideas
          LEFT OUTER JOIN idea_ratings
          ON ideas.id = idea_ratings.idea_id
          WHERE 
          ideas.question_id IN (#{q_ids.join(',')})
          AND ideas.role = 1
          AND idea_ratings.id IS null
          GROUP BY ideas.question_id|)
      
      self.questions.each{|question| question.member = member; question.unrated_ideas_count = 0 }
      unrated_ideas.each{|rec| self.questions.detect{|q| q.id==rec[1].to_i}.unrated_ideas_count = rec[0].to_i }

    end
    
  end  
  
  def assign_new_content(member,last_stat_update)
    q_ids = self.questions.map(&:id)
    q_ids = [0] if q_ids.size == 0
    
    self.new_content = {}
    self.questions.sort{|a,b| a.order_id <=> b.order_id}.each do |q|
      self.new_content[q.id] = {:id => q.id, :order_id => q.order_id, :text=> q.text, :talking_points => {}}
    end

    if member.id != 0
      # gets the unrated TP    
      self.new_talking_points = TalkingPoint.select('tp.*')
        .joins(" AS tp LEFT JOIN talking_point_acceptable_ratings AS tpar ON tp.id=tpar.talking_point_id AND tpar.member_id = #{member.id}",)
        .where("tpar.id IS NULL AND question_id IN (#{q_ids.join(',')})").order('tp.created_at ASC')
  
      self.new_talking_points.each{|tp| tp.is_new = true }
      self.new_talking_points_count = self.new_talking_points.count

      new_tp_ids = new_talking_points.map{|tp| tp.id.to_i }
      new_tp_ids = [0] if new_tp_ids.size == 0
      # now there may be some TP that have been updated since I rated them
      updated_talking_points = TalkingPoint.where("question_id IN (#{q_ids.join(',')}) AND version > 1 AND updated_at >= :last_visit AND id NOT IN (:new_tp_ids)",
        :new_tp_ids => new_tp_ids, :last_visit => last_stat_update).order('updated_at ASC')

      updated_talking_points.each{|tp| tp['updated'] = true }
      self.updated_talking_points_count = updated_talking_points.count
        
      if self.updated_talking_points_count > 0    
        # retrieve the last version of tp that was current on my last visit
        tp_versions = ActiveRecord::Base.connection.select_all(%Q|SELECT tp_id,
        (SELECT text from talking_point_versions where talking_point_id = tp_id and created_at < '#{last_stat_update}' order by created_at desc limit 1) AS text
        FROM (  VALUES #{updated_talking_points.map{|utp| "(#{utp.id})"}.join(',')} ) AS tp (tp_id)|)
    
        # if the old text isn't nil, replace talking_point.text with the diff

        tp_versions.each do |tp|
          if !tp['text'].nil?
            utp = updated_talking_points.detect{|utp| utp.id == tp['tp_id'].to_i }
            Differ.format = :html
            utp.text = Differ.diff_by_word(utp.text, tp['text'])
          end
        end
      end
    
      self.new_talking_points += updated_talking_points
    else
      # just show some recent talking points
      self.new_talking_points = TalkingPoint.where("question_id IN (#{q_ids.join(',')}) AND created_at >= :last_visit",
        :last_visit => last_stat_update).order('updated_at ASC')
      
      self.new_talking_points_count = self.new_talking_points.count
      self.updated_talking_points_count = 0
    end
    self.new_comments = Comment.includes(:author)
      .where("question_id IN (#{q_ids.join(',')}) AND parent_type = 13 AND comments.created_at >= :last_visit", 
        :last_visit => last_stat_update).order('comments.created_at ASC')

    # get id for TP needed to provide reference for comments under new/updated TP
    self.new_talking_points += TalkingPoint.find( self.new_comments.map(&:parent_id).uniq - self.new_talking_points.map(&:id) )

    # attach the talking points to the questions
    self.new_talking_points.each do |tp|
      tp.tp_comments = {}
      self.new_content[tp.question_id][:talking_points][tp.id] = tp
    end  

    # attach the comments to the talking points in the quetions
    #needed_tp_ids = []
    self.new_comments.each do |c|
      self.new_content[c.question_id][:talking_points][c.parent_id].comments[c.id] = c
    end  
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
  
  def create_team_plan_page(proposal_id)
    logger.debug "create_team_plan_page for id: #{self.id}, \"#{self.title}\""
    case self.initiative_id
      when 1..2
        filename = "#{Rails.root}/config/plan_page_template.yaml"
      when 4
        filename = "#{Rails.root}/config/plan_page_template-catalyst.yaml"
      when 5
        filename = "#{Rails.root}/config/plan_page_template-skyline.yaml"
      else
        filename = "#{Rails.root}/config/plan_page_template.yaml"
    end
    yml = YAML.load_file filename
  
    if !self.launched
      member = Member.find(self.org_id)
      
      # add an idea for the team
      team_idea = Idea.new  text: self.title, member_id: self.org_id, team_id: self.id, parent_id: self.id, order_id: 1, visible: true, version: 1, role: 4, aux_id: self.initiative_id
      team_idea.save(:validate => false)
      
      yml.each_pair { |key, value|
        rec = value
        # create a quesstion record
        question = Question.new :member_id=>self.org_id, :text=>rec['question'], :team_id=>self.id,
          :answer_criteria=>rec['answer_criteria'], :num_answers=>rec['num_answers'], :default_answer_id=>rec['default_answer_id'],
          :order_id=>rec['order_id'], :talking_point_criteria=>rec['talking_point_criteria'], 
          :talking_point_preferences=>rec['talking_point_preferences']
        question.save  
      
        # add an idea for each question
        idea = Idea.new  text: rec['question'], member_id: self.org_id, team_id: self.id, parent_id: self.id, 
          order_id: rec['order_id'], visible: true, version: 1, role: 3, aux_id: rec['default_answer_id']
        idea.save(:validate => false)
        # update ideas set question_id = id where role = 3;
        idea.question_id = idea.id
        idea.save(:validate => false)
      }
      
      # add team_id to the participation_events rec and find how many points did the originator get for this team_proposal and add to stats
      event = ParticipationEvent.find_by_event_id_and_item_id(9,proposal_id)
      event.team_id = self.id
      event.save

      ParticipantStats.create :member_id => self.org_id, :team_id => self.id, :points_total => event.points
      ProposalStats.create :team_id => self.id, :points_total => event.points
      
      self.launched = true
      self.archived = false
      self.save
      
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
