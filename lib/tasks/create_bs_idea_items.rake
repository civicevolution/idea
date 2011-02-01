namespace :bs_idea_retro do
  desc "Creates item records for the bs_ideas"
  task :create_bs_idea_items => :environment do
    puts 'create item records for bs_ideas'
 
    bs_ideas = BsIdea.all()
    puts "There are #{bs_ideas.size} bs_ideas"
  
    bs_ideas.each do |bsi|
      puts "bs_idea.id: #{bsi.id}"
      item = Item.find_by_o_id_and_o_type(bsi.id, 12)
      
      if item.nil?
      
        parItem = Item.find_by_o_id_and_o_type(bsi.question_id, 1)
        ancestors = parItem.ancestors.delete('{}').split(',') + [parItem.id]
  
        item = Item.new :o_id => bsi.id, :o_type => 12, :par_id => parItem.id, :team_id => bsi.team_id, 
          :target_id => 0, :target_type => 0, :sib_id=>0, :order=>0, :ancestors=>"{#{ancestors.join(',')}}"


        puts bsi.inspect
        puts parItem.inspect
        item.save
        puts item.inspect
      else
        puts "Idea has item"
      end
    end
  end
    
  desc "update the par id where target type is bs_idea"
  task :update_par_id => :environment do
    bs_coms = Item.all( :conditions=>'target_type = 11')
    puts "there are #{bs_coms.size} bs coms"
    
    bs_coms.each do |i|
      item = Item.find_by_o_id_and_o_type(i.target_id, 12) 
      i.par_id = item.id
      i.save
    end
    
  end
    
end
  
  