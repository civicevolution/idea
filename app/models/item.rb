class Item < ActiveRecord::Base
  
  belongs_to :team
  belongs_to :question, :foreign_key => "o_id",
               :conditions => 'o_type = 1'
  belongs_to :answer, :foreign_key => "o_id",
              :conditions => 'o_type = 2'
  belongs_to :comment, :foreign_key => "o_id",
              :conditions => 'o_type = 3'
  belongs_to :list, :foreign_key => "o_id",
              :conditions => 'o_type = 7'

  belongs_to :page, :foreign_key => "o_id",
            :conditions => 'o_type = 9'

  belongs_to :rating, :foreign_key => 'id'
  belongs_to :thumbs_rating, :foreign_key => 'id'
  
  attr_accessible :team_id, :o_id, :o_type, :par_id, :order, :sib_id, :ancestors, :target_id, :target_type
  
  
end
