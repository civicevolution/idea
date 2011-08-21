module PlanHelper

  def show_new_comment(comment)

    author = link_to "#{comment.author.first_name} #{comment.author.last_name}", {:action=>'author_info', :id=>comment.author.ape_code}, {:class=>'com_author'}
    quote = comment.text.match(/\[quote=(.*)\](.*)\[\/quote\]/i)
    fields = comment.text.match(/\[quote="(.*)"\](.*)\[\/quote\]/i)
    if fields
      #debugger
      name = fields[1]
      quote = fields[2]
      text = comment.text.sub(/\[quote.*quote\]/i,'').sub(/^\s*/,'').sub(/\s$/,'')
      
      quote_com = simple_format(auto_link(h(quote), :all, :target => "_blank"))
      com = simple_format(auto_link(h(text), :all, :target => "_blank"))
      %Q|<p>#{author}</p>\n<div class="quote"><p class="quote">#{name} said:</p>#{quote_com}</div>\n#{com}|
      #%Q|<p>(#{comment.id.to_s}) #{author}</p>\n<div class="quote"><p class="quote">#{name} said:</p>#{quote_com}</div>\n#{com}|      
    else
      com = simple_format(auto_link(h(comment.text), :all, :target => "_blank"))
      com.sub(/<p>/,"<p>" +   author + ' ')
      #com.sub(/<p>/,"<p>(#{comment.id.to_s}) " +   author + ' ')      
    end    
  end


end
