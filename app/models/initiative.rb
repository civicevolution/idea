class Initiative < ActiveRecord::Base
  
  has_many :initiative_members, :class_name => 'InitiativeMembers' 
  has_many :members, :through => :initiative_members
  
end
