# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:atom'=>"http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "2029 and Beyond Teams"
    xml.description "2029 and Beyond teams committed to developing community solutions"
    xml.link "http://#{@host}/#get_started"
    xml.tag! "atom:link", :href=>"http://#{@host}/teams/rss", :rel=>"self", :type=>"application/rss+xml"
    
    for team in @teams
      xml.item do
        xml.title team.title
        xml.description team.solution_statement
        xml.pubDate team.created_at.utc.rfc822
        xml.link "http://#{@host}/team/proposal/#{team.id}"
        xml.guid "http://#{@host}/team/proposal/#{team.id}"
      end
    end
  end
end
