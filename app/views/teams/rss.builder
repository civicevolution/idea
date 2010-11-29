# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "2029 and beyond Teams"
    xml.description "2029 and beyond teams committed to developing community solutions"
    xml.link "http://#{@host}/#get_started"
    
    for team in @teams
      xml.item do
        xml.title team.title
        xml.description team.solution_statement
        xml.pubDate team.created_at.to_s()#(:rfc822)
        xml.link "http://#{@host}/team/proposal/#{team.id}"
        xml.guid "http://#{@host}/team/proposal/#{team.id}"
      end
    end
  end
end
