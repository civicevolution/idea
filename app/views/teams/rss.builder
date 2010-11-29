# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:atom'=>"http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "2029 and beyond Teams"
    xml.description "2029 and beyond teams committed to developing community solutions"
    xml.link "http://#{@host}/#get_started"
    #<link>http://2029.civicevolution.org/#get_started</link> 
    xml.link :href=>"http://dallas.example.com/rss.xml", :rel=>"self", :type=>"application/rss+xml"
    #xml.link "href"=>"http://dallas.example.com/rss.xml" "rel"=>"self" "type"=>"application/rss+xml"
    #xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'feeds', :action => 'atom')
    
    #<atom:link href="http://dallas.example.com/rss.xml" rel="self" type="application/rss+xml" />
    
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
