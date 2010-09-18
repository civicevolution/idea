class TeamRegistration < ActiveRecord::Base
  belongs_to :team
  belongs_to :member
  
  #validates_length_of :text, :in => 5..1000, :allow_blank => false
  validate :check_team
  validate :eligible_to_join
  validates_presence_of :accept_groundrules, :message => "must accept the ground rules"

  after_create :check_if_I_should_launch_team
  
  attr_accessor :accept_groundrules
  attr_accessor :text
  attr_accessor :team
  attr_accessor :num_members
  attr_accessor :host
  attr_accessor_with_default :team_just_launched, false
  
  
  def self.my_teams(member_id)
    TeamRegistration.find(:all, 
      :select => 't.title, t.id', 
      :conditions => ['tr.member_id = ?', member_id],
      :joins => 'as tr inner join teams as t on t.id = tr.team_id' 
    )
  end
  
  def self.count_members(team_id)
    TeamRegistration.count(:conditions => ['team_id = ?', team_id]);
  end

  def self.member_ids(team_id)
    mem_ids = TeamRegistration.all(:select=>'member_id',:conditions => ['team_id = ?', team_id])
    mem_ids.map { |tr| tr.member_id }
  end

  
  private
  
  def check_if_I_should_launch_team
    self.num_members = TeamRegistration.count_members(self.team_id)
    logger.debug "check_if_I_should_launch_team min members: #{self.team.min_members}, num_members: #{self.num_members}"
    if self.num_members.to_i >= self.team.min_members.to_i && self.team.launched == false
      logger.debug "Launch this team"
      self.team.create_team_workspace(self)
      team_just_launched = self.team.launched        
    else
      logger.debug "Do not launch this team"
    end
  end
  
  def check_team
    self.team = Team.find_by_id(self.team_id, :limit=>1)
    if self.team.nil?
      # is this a valid team?
      errors.add(:base, "This is not a valid team, please return to the home page and try again")
      return
    end
    self.num_members = TeamRegistration.count_members(self.team_id)
    if self.team.max_members.to_i <= self.num_members.to_i
      # is team accepting members
      errors.add(:base, "This team seems to be full, please return to the home page and try again")
      return
    end
    
  end
  
  def eligible_to_join
    member = Member.find_by_id(self.member_id, :limit=>1)
    if member.nil?
      # signed in
      errors.add(:base, "You must be signed in to CivicEvolution before you can join a team")
      return
    end
    email = Member.find_by_id(self.member_id).email
    if !( email.match(/cgg.wa.gov.au$/i) || email.match(/civicevolution.org$/i) )
      # eligible for this initiative
      errors.add(:base, "You must have an offical cgg.wa.gov.au email address to join this team")  
    elsif TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.team_id)
      errors.add(:base, "You are already a member of this team")  
    elsif !Member.find_by_id(self.member_id).confirmed
      # confirmed
      errors.add(:base, "You must confirm your CivicEvolution registration before you can join a team") 
    end
    self.status = 'confirmed'
  end
  
end
