require 'differ'
require 'diff/lcs'

class ItemDiff < ActiveRecord::Base
  
  belongs_to :question, :foreign_key => "o_id",
               :conditions => 'o_type = 1'
  belongs_to :answer, :foreign_key => "o_id",
              :conditions => 'o_type = 2'
  belongs_to :list_item, :foreign_key => "o_id",
              :conditions => 'o_type = 8'
  

  attr_accessor :item
  attr_accessor :base_version_of_request
  
  before_validation :init_item_details
  validate :is_base_version_valid?
  
  before_save :create_diff

  def show_history
    begin
      logger.debug "show_history: self.item.id: #{self.item.id}, self.item.o_type: #{self.item.o_type}"
      Differ.format = :html
      diff_recs = ItemDiff.find_all_by_o_id_and_o_type(self.item.id,self.item.o_type, :order => 'ver')
      earlier_ver = ''
      html_diffs = []
      diff_recs.each do |d|
        earlier_patched_to_next = Diff::LCS.patch(earlier_ver,Marshal.load(d.diff))
        #logger.debug "original_patched_to_current: #{earlier_patched_to_next}"
        html_diff = Differ.diff_by_word(earlier_patched_to_next, earlier_ver)
        # make vertical space appear in html
        html_diff = html_diff.to_s.gsub(/\n/,'<br/>').gsub(/\r/,'')
  #      html_diff.to_s.each_byte do |c| 
  #        logger.debug "#{c.chr}: #{c}"
  #      end
        #logger.debug "html_diff: #{html_diff}"
        drec = {:ver => d.ver, :html_diff => html_diff}
        html_diffs.push drec
        earlier_ver = earlier_patched_to_next
      end
      return html_diffs.reverse
    rescue Exception => e  
      logger.error "Item_diff show history failed for item.id: #{self.item.id}, type: #{self.item.o_type}\nError: #{e.message}"
      return [{:ver=>1, :html_diff=>"<p>Sorry, we could not generate this history. We apologize for the inconvenience and we have been notified of this problem.</p>"}]
    end
  end
  
  def create_diff
    last_text_base = self.item.previousText || '' # use the text version that was in the db when this update was initiated
    logger.debug "create_diff from last_text_base: #{last_text_base}"
    
    @new_ver = true # default to new version everytime for now

    if @new_ver
      self.ver = self.item.previousVer ? self.item.previousVer + 1 : 1
    else
      logger.debug "Update the existing diff record - this means recreating the base record on which the current diff is based"
      #last_text_base = ...
      self.ver = this.self.previousVer + 1 # force updates for now
    end
    
    begin
      # save a copy of this versions text for troubleshooting diffs
      ItemVersions.new( :item_id=> self.item.id, :item_type=> self.o_type, :ver=> self.ver, :text=>self.item.text).save
    rescue Exception => e
      logger.error "Item_diff create_diff save version failed for item.id: #{self.item.id}, type: #{self.o_type}\nError: #{e.message}"
    end
    
    raw_diffs = Diff::LCS.diff(last_text_base, self.item.text)
    self.diff = Marshal.dump(raw_diffs)
  end
  
  def init_item_details
    # copy attributes from the target item to the revision history record
    #logger.debug "ItemDiff init values from the item to be archived"
    self.o_id = self.item.id
    self.o_type = self.item.o_type
    self.member_id = self.item.member_id
    self.anonymous = self.item.anonymous
    self.base_version_of_request = self.item.ver
  end
  
  def is_base_version_valid?
    # 1. before I create/update diff I need to make sure the user has the started from the most recent version
    # based on the version and updated_at timestamp
    # 2. also check that I have the lock
    # 3. determine if I want to create a new version, or update the current version
    
    if self.item.previousVer == 0
      @new_ver = true; # there is no diff yet, so make one now, no need to validate
      return
    end
    
#    if self.base_version_of_request != @item_in_db.ver # || self.item.ts != @item_in_db.updated_at
#      errors.add(:form, "Diff is not valid")
#    end
#    logger.debug "Base version is okay. make the diff and store, Current version is #{@item_in_db.ver}"
    
    @new_ver = true; # assume I am creating a new diff
  end
   
end
