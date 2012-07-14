class AnswerDiff < ActiveRecord::Base
  belongs_to :answer
  
  attr_accessible :answer_id, :member_id, :version, :diff, :text
  
  def o_type
    17 #type for Answer diff
  end
  def type_text
    'answer diff' #type for Answers
  end
  
end
