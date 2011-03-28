namespace :pub_disc_retro do
  desc "Find orphaned comments and update their item records so they will appear in the question discussion"
  task :reunite_orphan_comments => :environment do
    puts 'find orphan comments'

    orphans = Item.find_by_sql(%Q|select * from items where team_id > 10017 and o_type = 3 and sib_id = 0 and par_id in (select id from items where o_type =11) order by team_id, par_id|)

    puts "There are #{orphans.size} orphans"

    orphans.each do |o|
      # get last id in ancestors as par id
      #puts "ORIG ITEM: #{o.inspect}"
      com = Comment.find(o.o_id)
      com.publish = true
      com.save
    
    
      new_anc = o.ancestors.sub(/,\d+\}/,'}')
      new_par_id = new_anc.match(/(\d+)\}/)[1]
    
      new_item = Item.find(new_par_id)
      if new_item.o_type.to_i == 1
        #puts "Assign item to parent question: item: #{o.id}, anc: #{o.ancestors}, new par id: #{new_par_id}, new ancestors: #{new_anc} "
        o.par_id = new_par_id
        o.ancestors = new_anc
        puts "1 NEW ITEM: #{o.inspect}"
        o.save
      
      
      elsif new_item.o_type.to_i == 4
      
        #select * from items where team_id = 10019 and o_type = 9 and "order" = 2;
        #1697
        #
        #select * from items where team_id = 10019 and o_type = 1 and par_id = 1697
      
        new_item = Item.find_by_sql(%Q|SELECT * FROM items where team_id = #{o.team_id} and o_type = 1 AND o_id in ( select id from questions where text ~* 'what is the change')|)[0]
        #puts "Re-assign this item from team discussion to first question discussion: #{o.inspect}"
        #puts "Question (new) item: #{new_item.inspect}"
        #puts "new_item.o_id: #{new_item.o_id}"
      
        #puts "XXXXXXXX  new_item.id: #{new_item.id}"
      
        o.par_id = new_item.id
        anc = new_item.ancestors.sub(/\}/, ',' + new_item.id.to_s + '}')
        #puts "acn: #{anc}"
        o.ancestors = anc
        puts "2 NEW ITEM: #{o.inspect}"
        o.save 
      
      else
        puts "***********"
        puts "orphan: #{o.inspect}"
        puts "new parent is #{new_item.inspect}"
        puts "***********"
      
      end

    end

  end
  
  task :reunite_orphan_comment_siblings => :environment do
    puts 'find orphan comments'

    orphans = Item.find_by_sql(%Q|select * from items where team_id > 10017 and o_type = 3 and sib_id != 0 and par_id in (select id from items where o_type =11) order by team_id, par_id|)

    puts "There are #{orphans.size} orphan siblings"

    orphans.each do |o|
      # get last id in ancestors as par id
      puts "ORIG ITEM: #{o.inspect}"
      
      com = Comment.find(o.o_id)
      com.publish = true
      com.save
      
      # get sib item
      new_item = Item.find(o.sib_id)
    
      new_par_id = new_item.par_id
      new_anc = new_item.ancestors.sub(/\}/,',' + o.sib_id.to_s + '}')
      
      o.par_id = new_par_id
      o.ancestors = new_anc
      puts "1 NEW ITEM: #{o.inspect}"
      o.save
      

    end

  end
  
  
  
  
end