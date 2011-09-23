module IdeaHelper
  
  def show_author_comment(author,ape_code,text)

    author = link_to author, display_profile_path(ape_code), {:class=>'com_author', :remote=>true}
    quote = text.match(/\[quote=(.*)\](.*)\[\/quote\]/i)
    fields = text.match(/\[quote="(.*)"\](.*)\[\/quote\]/i)
    if fields
      #debugger
      name = fields[1]
      quote = fields[2]
      text = text.sub(/\[quote.*quote\]/i,'').sub(/^\s*/,'').sub(/\s$/,'')
      
      quote_com = simple_format(auto_link(h(quote), :all, :target => "_blank"))
      com = simple_format(auto_link(h(text), :all, :target => "_blank"))
      %Q|<p>#{author}</p>\n<div class="quote corner"><p class="quote">#{name} said:</p>#{quote_com}</div>\n#{com}|
    else
      com = simple_format(auto_link(h(text), :all, :target => "_blank"))
      com.sub(/<p>/,'<p>' + author + ' ')
    end    
  end
end
