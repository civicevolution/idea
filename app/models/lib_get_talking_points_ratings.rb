# move this to library when it is stable
# /lib is not reloaded in dev, but putting this module in models means it will be reloaded each time it is referenced

module LibGetTalkingPointsRatings
  
  def get_talking_point_ratings(member)
    self.member = member

    case self.type_text
      when 'team'
        questions = self.questions
      when 'question'
        questions = [self]
    end
    
    question_ids = questions.map{|q| q.id}
    talking_point_ids = []
    comment_ids = []
    questions.each do |q|
      q.talking_points_to_display = q['talking_points_to_display'] || q.top_talking_points
      q.talking_points_to_display.each do |tp| 
        talking_point_ids << tp.id
      end
      q['comments_to_display'] ||= []
      q['comments_to_display'].each do |c|
        comment_ids << c.id
      end
    end

    tpp = TalkingPointPreference.sums(talking_point_ids)
    tpr = TalkingPointAcceptableRating.sums(talking_point_ids)
    my_preferences = TalkingPointPreference.my_votes(talking_point_ids, self.member.id)
    my_ratings = TalkingPointAcceptableRating.my_votes(talking_point_ids, self.member.id)

    question_coms = Question.com_counts(question_ids, self.member.last_visit_ts)
    talking_point_coms = TalkingPoint.com_counts(talking_point_ids, self.member.last_visit_ts)
    comment_coms = Comment.com_counts(comment_ids, self.member.last_visit_ts)

    assign_stats( 
      :questions => questions,
      :question_coms => question_coms, 
      :talking_point_coms => talking_point_coms,
      :comment_coms => comment_coms,
      :tpp => tpp,
      :tpr => tpr, 
      :my_preferences => my_preferences,
      :my_ratings => my_ratings
    )
    
    true
  end
  

  def assign_stats stats
    stats[:question_coms] ||= []
    stats[:comment_coms] ||= []
    
    stats[:questions].each do |q| 
      qcom = stats[:question_coms].detect{|qc| qc['ques_id'].to_i == q.id}
      if !qcom.nil?
        q.coms = qcom['coms'].to_i
        q.new_coms = qcom['new_coms'].to_i
        q.num_talking_points = qcom['num_talking_points'].to_i
        q.num_new_talking_points = qcom['num_new_talking_points'].to_i
      end

      q.talking_points_to_display.each do |tp| 
        pref = stats[:tpp].detect{|p| p.talking_point_id == tp.id}
        tp.preference_votes = pref.count.to_i unless pref.nil? 
        
        tp.rating_votes = [0,0,0,0,0]
        stats[:tpr].select{|rec| rec.talking_point_id == tp.id}.each do |r|
          tp.rating_votes[r.rating-1] = r.count.to_i
        end
        
        my_pref = stats[:my_preferences].detect{|p| p.talking_point_id == tp.id}
        tp.my_preference = my_pref.nil? ? false : true 
        
        my_rating = stats[:my_ratings].detect{|r| r.talking_point_id == tp.id}
        tp.my_rating = my_rating.rating.to_i unless my_rating.nil?

        tpcom = stats[:talking_point_coms].detect{|tpc| tpc['talking_point_id'].to_i == tp.id}
        if !tpcom.nil?
          tp.coms = tpcom['coms'].to_i
          tp.new_coms = tpcom['new_coms'].to_i
        else
          tp.coms = 0
          tp.new_coms = 0
        end
      end
      
      q['comments_to_display'].each do |c|
        ccom = stats[:comment_coms].detect{|cc| cc['comment_id'].to_i == c.id}
        c.coms = ccom['coms'].to_i
        c.new_coms = ccom['new_coms'].to_i
      end
      
    end
  end
  
  
  
end