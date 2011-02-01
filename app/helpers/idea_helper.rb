module IdeaHelper
  
  def show_author_comment(author,ape_code,text)
    
    com = simple_format(auto_link(h(text), :all, :target => "_blank"))
    
    author = link_to author, {:action=>'author_info', :id=>ape_code}, {:class=>'com_author'}
    
    com.sub(/<p>/,'<p>' + author + ' ')
    
  end
end
