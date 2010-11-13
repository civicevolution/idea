class ActiveSupport::TimeWithZone
  def to_s
    self.iso8601
  end
end

# disable the sql logging
class ActiveRecord::ConnectionAdapters::AbstractAdapter
  #def log_info(*args); end
end

class ActiveRecord::Base
  
  def create_item_record
    #logger.debug "create_item_record for par_id: #{self.inspect}"
    #logger.debug "create_item_record for par_id: #{self.par_id}"
    #logger.debug "create_item_record for insert_mode: #{self.insert_mode}"
    
    # save an item record
    # after_create create an item record  
    item = Item.new :o_id => self.id, :o_type => self.o_type, :par_id => self.par_id, :team_id => self.team_id, :target_id => self.target_id || 0, :target_type => self.target_type || 0
#    ancestors: "0",  Do I need to set the ancestors?
    
    if self.par_id == 0 
      ancestors = [0]
    else
      parItem = Item.find(self.par_id)
      ancestors = parItem.ancestors.delete('{}').split(',') + [self.par_id]
      if self.o_type == 3 # this is a comment, record the parent item's member id
        #logger.debug "Set par_member_id from parItem: #{parItem.inspect}"
        case
          when item.target_type == 2 # answer
            self.par_member_id = ActiveRecord::Base.connection.select_value( "SELECT member_id FROM answers WHERE id = #{item.target_id}")
          when item.target_type == 11 # bs_idea
            self.par_member_id = ActiveRecord::Base.connection.select_value( "SELECT member_id FROM bs_ideas WHERE id = #{item.target_id}")

          when parItem.o_type == 1 # question
            self.par_member_id = 0
          when parItem.o_type == 3 # comment
            self.par_member_id = ActiveRecord::Base.connection.select_value( "SELECT member_id FROM comments WHERE id = #{parItem.o_id}")
        end
      end
    end
    item.ancestors = "{#{ancestors.join(',')}}"

    max = Item.maximum(:order, :conditions => "par_id = #{self.par_id}") 
    max = (max.nil? && 0 ) || max += 1
    item.order = max
    
    
    #Always have the server set the insert_mode
    #if self.insert_mode.nil?
      # insert_mode is set in dynamic version, set here for static version'
      parItem = Item.find(self.par_id)
      logger.debug "set insert_mode, parItem: #{parItem.inspect}"
      if parItem.o_type != self.o_type # if it is a different type, then it cannot be a sibling
        self.insert_mode = 'child'        
      else
        older_sib = Item.exists?(['sib_id = ? AND created_at < CURRENT_TIMESTAMP AT TIME ZONE \'UTC\' - interval \'30 sec\'', self.par_id ])
        logger.debug "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX check for older sibling self.par_id: #{self.par_id}, older_sib: #{older_sib}"
        # can only be a sibling if target has no child more than a few minutes old
        if older_sib
          self.insert_mode = 'child'
        else
          self.insert_mode = 'sibling'
        end
      end
    #end
    
    if self.insert_mode == 'sibling'
      # use same par_id as target
      parItem = Item.find(self.par_id) if !parItem
      # this test is repeated because dynamic page submit bypassed test above
      if parItem.o_type == self.o_type # can only be a sibling to the same type of object
        
        tentative_sibling = parItem
        # now make sure tentative_sibling doesn't already have a sibling
        # find the most recent sibling with no younger sibling
        
        while true
          logger.debug "tentative_sibling: #{tentative_sibling.inspect}"
          next_sibling = Item.find_by_sib_id(tentative_sibling.id)
          if next_sibling.nil?
            break
          end
          tentative_sibling = next_sibling
        end
        
        item.par_id = tentative_sibling.par_id
        item.sib_id = tentative_sibling.id
        
      end
    end
    #logger.debug "create_item_record: #{item.inspect}"
    saved = item.save
    self.item_id = item.id
    #logger.debug "create_item_record saved: #{saved}"

  end

  def delete_item_record
    # after_destroy delete the ratings and the item record  
    item = Item.find_by_o_id_and_o_type(self.id,self.o_type)
    self.item_id = item.id
    self.team_id = item.team_id
    #logger.debug "delete ratings and item_record for type: #{self.o_type}, id: #{self.id}, with item.id: #{item.id}"

    case self.o_type
      when 1
        rating = Rating.find_by_item_id(item.id)
      when 2
        rating = Rating.find_by_item_id(item.id)
      when 3
        rating = ThumbsRating.find_by_item_id(item.id)
    end
    #logger.debug "rating: #{rating.inspect}"
    rating.destroy if rating 
    
    # clean up the item placeholders that are not needed anymore
    # either placeholder parents or placeholder earlier siblings
    # do this iteratively, everytime I destroy an item placeholder, see if its parent or previous sibling is a placeholder that can be destroyed
    # do sibling first and then do the parent
    
    # remove the item record, or clear its o_id
    if !Item.exists?(['par_id = ? OR sib_id = ?', item.id, item.id])
      #logger.debug "remove item record"
      item.destroy
      destroy_item_placeholder(item.sib_id) if item.sib_id > 0
      destroy_item_placeholder(item.par_id) if item.par_id > 0
      self.itemDestroyed = true
    else
      # clear the object_id since it has been deleted, but this item won't be deleted
      item.o_id = 0
      item.save
      self.itemDestroyed = false
      return
    end  
    

  end
  
  def destroy_item_placeholder(id)
    item = Item.find(id)
    if item.o_id == 0 && !Item.exists?(['par_id = ? OR sib_id = ?', id, id])
      item.destroy
      destroy_item_placeholder(item.sib_id) if item.sib_id > 0
      destroy_item_placeholder(item.par_id) if item.par_id > 0
    end
  end


  def check_team_access
    logger.debug "check_team_access, @par_id: #{@par_id}"
    @team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_id(@par_id).team_id )
    raise TeamAccessDeniedError, "In check_team_access for par_id: #{@par_id}" if @team.nil?
    self.team_id = @team.id # this will be used to construct the item record
    #logger.debug "Member of team #{@team.title}"
    @team
  end  

  def check_rating_access
    logger.debug "check_rating_access, @par_id: #{@par_id}"
    @team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_id(self.item_id).team_id )
    raise TeamAccessDeniedError, "In check_team_access for par_id: #{@par_id}" if @team.nil?
    self.team_id = @team.id # this will be used to construct the item record
    #logger.debug "Member of team #{@team.title}"
    @team
  end  
  
  
  def check_item_edit_access
    logger.debug "check_item_access, id: #{self.id}"
    logger.debug "check_item_access, o_type: #{self.o_type}"
    logger.warn "****** WARNING: Anyone can edit existing items, update in active_record_extensions.check_item_access"
    case self.o_type
      when 1
        # who can edit a question
        
      when 2
        # who can edit an answer
        
      when 3
        # who can edit a comment
    end
  end  

  def check_item_delete_access
    logger.debug "check_item_delete_access for type: #{self.o_type}, id: #{self.id}"
    if self.o_type == 8
      item = Item.find_by_o_id_and_o_type(self.list_id,7)
    else
      item = Item.find_by_o_id_and_o_type(self.id,self.o_type)
    end
    self.team_id = item.team_id  
    
    logger.debug "check_item_delete_access, id: #{self.id}"
    logger.debug "check_item_delete_access, o_type: #{self.o_type}"
    logger.warn "****** WARNING: Anyone can delete existing items, update in active_record_extensions.check_item_delete_access"
    case self.type
      when 1
        # what determines if a question can be deleted?
        # who can delete a question
      
      when 2
        # what determines if an answer can be deleted?
        # who can delete an answer
      
      when 3
        # what determines if a comment can be deleted?        
        # who can delete a comment
    end
  end

  
end