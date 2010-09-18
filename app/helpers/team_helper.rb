module TeamHelper


  def render_item(i,r_types)
    #partial, object, items_child_sorted, item_siblings, count, score, up, down, rated = get_item(i)
    #logger.debug "render_item i: #{i.inspect}"
    partial, object, items_child_sorted, item_siblings = get_item(i)
    if partial
      divClass = (i.sib_id > 0 ? 'item sibling ' : 'item top_sibling ') + object.class.to_s
      #divClass += ' ' + object.classname if defined? object.classname && !object.classname.nil?
      res = %Q|<div class= "#{divClass}" id="i#{i.id}" item_id="#{i.id}">|
      #res += render(:partial => partial, :object => object, :locals => { :item => i, :count => count, :score => score,  :up => up, :down => down, :rated => rated} )
      res += render(:partial => partial, :object => object, :locals => { :item => i} )
      items_child_sorted.each {|i| res += render_item(i,r_types) if r_types == 'all' || r_types[i.o_type] }
      item_siblings.each {|i| res += render_item(i,r_types) if r_types == 'all' || r_types[i.o_type] }
      res += %q|</div>|
    end
    res || ''
  end


  def get_item(i)
    #logger.debug "get_items: item is #{i} id: #{i.id}, o_type: #{i.o_type}, o_id: #{i.o_id}, par_id: #{i.par_id}"
    case i.o_type 
    	when 1
        object = @questions.detect { |q| q.id == i.o_id }
        partial = 'question'
    	when 2
        object = @answers.detect { |a| a.id == i.o_id }
        partial = 'answer'          
    	when 3 
        object = @comments_with_ratings.detect { |c| c.id == i.o_id }
        partial = 'comment'   
      when 5  #do something with the chat_session
        logger.debug "do something with the chat_session"
        object = ChatSession.new(:id=>i.o_id)
        #object = { :id=>i.o_id, :class=>'Chat_session' }
        partial = 'chat_session'   
    	when 7
        #object = @lists.detect { |c| c.id == i.o_id }
        #partial = 'list'   
        #if object
        #  #@this_list_items = @list_items.find_all {|li|  li.list_id == object.id } 
        #  @this_list_items = @list_items.find_all {|li|  li[:list_id] == object.id }           
        #  #.find_all {|li|  li.list_id == object.id }  
        #  #@list_items = [{:text=>'hola AA', :title =>'tite'},{:text=>'hola2 AA', :title =>'tite2'}];
        #end
      when 9  # page
        object = @pages.detect { |p| p.id == i.o_id }
        partial = 'page'   
      when 10  # team info, use team object for now
        object = @team
        partial = 'team_info'   
    end    
    
    # if an item has been deleted, but it had children (such as a comment), the item record exists but not the comment record, so use a missing partial
    if object.nil?
      partial = 'deleted'
      if i.o_type == 1111
        partial = nil #
      end
    end
    
    if i.o_type == 33333
      partial = nil
    end
    
    if i.o_type == 1
      # don't show children of questions, I will get them separately in the qppropriate containers
      items_child_sorted = []
    else
      items_child_sorted = @items.find_all {|it| it.par_id == i.id && it.sib_id == 0 }.sort {|a,b| a.order <=> b.order }
      #logger.debug "items_child_sorted: #{items_child_sorted}"
    end
    #item_sibling = @items.detect { |it| it.sib_id == i.id }
    item_siblings = @items.find_all { |it| it.sib_id == i.id }.sort {|a,b| a.id <=> b.id }
    #logger.debug "item_sibling: #{item_sibling.inspect}"
    #return partial, object, items_child_sorted, item_siblings, rating ? rating.count : 0, rating ? rating.average.to_f : 0.to_f, 
      #thumbs_rating ? thumbs_rating.up : 0, thumbs_rating ? thumbs_rating.down : 0, my_thumbs_rating ? 1 : 0;
    return partial, object, items_child_sorted, item_siblings

      
  end
  
end
