class CallToActionEmail < ActiveRecord::Base
    
    def self.get_most_recent
      email = CallToActionEmail.find_by_id(1)
      email = CallToActionEmail.first() if email.nil?
      if email.nil?
        email = CallToActionEmail.new(
          :scenario=>'Welcome', :version=>0, :subject=>'Welcome to CivicEvolution', :message=>'Hello <%=@recipient.first_name%>,\\n\nWelcome to CivicEvolution.\n\nCheers,\n\nBrian'
        )
        email.save
      end
      email
    end
    def self.get_scenarios
      CallToActionEmail.all(:select=>'DISTINCT(scenario)')
    end
  
    def self.get_versions(selected_scenario)
      logger.debug "get_versions: #{selected_scenario}"
      CallToActionEmail.all(:select=>'id, scenario, version, description, updated_at',
        :conditions=>['scenario = ?',selected_scenario])
    end
    
    def self.get_scenario(selected_scenario)
      logger.debug "get_scenario: #{selected_scenario}"
      CallToActionEmail.first(
        :conditions=>['scenario=?',selected_scenario],
        :order=>'version DESC'
      )
    end
    
    def self.get_version(selected_scenario,selected_version)
      CallToActionEmail.first(
        :conditions=>['scenario=? AND version = ?',selected_scenario,selected_version]
      )
    end
    
    def self.get_recipients_by_query( recipient_source )
      logger.debug "recipient_source: #{recipient_source}, recipient_source.to_i: #{recipient_source.to_i}"
      case recipient_source.to_i
        when 0
          #Registered, no team (49)
          #Member.find_all_by_id([1,119]) #email('brian@civicevolution.org')]
          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, id AS mem_id, 0 AS team_id
          FROM members
          WHERE id IN (1,119)|)

        when 1
          #Registered, no team (49)
          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, 0 AS team_id
          FROM members m, initiative_members im
          WHERE m.id = im.member_id
          AND im.initiative_id = 2
          AND m.id NOT IN (SELECT member_id FROM team_registrations)|)

        when 2
          #Joined a team that hasn't launched (31)
          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id
          FROM members m, initiative_members im, team_registrations tr, teams t
          WHERE im.initiative_id = 2
          AND t.launched = false
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY title, m.id|)
          
        when 3
          #Joined a team that launched but haven't made a comment yet (27)

          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id
          FROM members m, initiative_members im, team_registrations tr, teams t
          WHERE im.initiative_id = 2
          AND m.id NOT IN (SELECT member_id FROM comments WHERE member_id = m.id AND team_id = t.id)
          AND t.launched = true
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY title, m.id|)

        when 4
          #Joined a team and made at least one comment (21)

          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id,
          (SELECT COUNT(*) FROM comments WHERE member_id = m.id AND team_id = t.id) AS comments
          FROM members m, initiative_members im, team_registrations tr, teams t, comments c
          WHERE im.initiative_id = 2
          AND m.id = c.member_id
          AND t.id = c.team_id
          AND t.launched = true
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY comments, title, m.id|)
          
        when 5
          #Registered, no team (49)
          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, 0 AS team_id
          FROM members m, initiative_members im
          WHERE m.id = im.member_id
          AND im.initiative_id = 1
          AND m.id NOT IN (SELECT member_id FROM team_registrations)|)

        when 6
          #Joined a team that hasn't launched (31)
          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id
          FROM members m, initiative_members im, team_registrations tr, teams t
          WHERE im.initiative_id = 1
          AND t.launched = false
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY title, m.id|)
          
        when 7
          #Joined a team that launched but haven't made a comment yet (27)

          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id
          FROM members m, initiative_members im, team_registrations tr, teams t
          WHERE im.initiative_id = 1
          AND m.id NOT IN (SELECT member_id FROM comments WHERE member_id = m.id AND team_id = t.id)
          AND t.launched = true
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY title, m.id|)

        when 8
          #Joined a team and made at least one comment (21)

          Member.find_by_sql(
          %q|SELECT distinct first_name, last_name, email, m.id AS mem_id, title, t.id AS team_id,
          (SELECT COUNT(*) FROM comments WHERE member_id = m.id AND team_id = t.id) AS comments
          FROM members m, initiative_members im, team_registrations tr, teams t, comments c
          WHERE im.initiative_id = 1
          AND m.id = c.member_id
          AND t.id = c.team_id
          AND t.launched = true
          AND m.id = im.member_id
          AND tr.member_id = m.id
          AND tr.team_id = t.id
          AND t.id > 10018
          ORDER BY comments, title, m.id|)
          
          
      end
    end
end
