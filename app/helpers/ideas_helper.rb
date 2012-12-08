module IdeasHelper
  
  def comment_with_author(comment)
    com = simple_format(auto_link(h(comment.text), :all, :target => "_blank"))
    com.sub(/<p>/,'<p>' + 
      link_to( "#{comment.author.first_name} #{comment.author.last_name}", display_profile_path(comment.author.ape_code), {:class=>'com_author', :remote=>true}) + ' ')
  end

  def endorsement_with_member(endorsement)
    com = simple_format(auto_link(h(endorsement.text), :all, :target => "_blank"))
    com.sub(/<p>/,'<p>' + 
      link_to( "#{endorsement.member.first_name} #{endorsement.member.last_name}", display_profile_path(endorsement.member.ape_code), {:class=>'com_author', :remote=>true}) + ' ')
  end
  
end