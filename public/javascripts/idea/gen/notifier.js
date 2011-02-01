//console.log("loading notifier.js v1")

NOTIFIER = {
  inform: function(report){
		temp.report = report
		// this must only be called/counted once
    //console.log("Notifier.inform")
		// what do I need to record about the new item?
		// report { type, id, page_id, [target_type, target_id]}  optional for idea and answer comments
		var page = $('div#i' + report.page_id)
		switch(report.type){
			case 'comment':
				++this.data_model['page_' + report.page_id].team_coms;
				++this.data_model.totals['page_' + report.page_id];
				$('div.tabs > ul > li', page).eq(0).find('div.new_items').html(this.data_model['page_' + report.page_id].team_coms + ' new')
				switch(report.target_type){
					case 'bs_idea':
						++this.data_model['page_' + report.page_id].idea_coms;
						$('div.tabs > ul > li', page).eq(1).find('div.new_items').html(
							Number(this.data_model['page_' + report.page_id].ideas) + 
							Number(this.data_model['page_' + report.page_id].idea_coms) + ' new');
							//console.log("call set time out for idea: " + report.target_id)
							setTimeout( function(){ update_embedded_discussion_links( this.td ); }.bind( { td: $('div#bs_' + report.target_id).closest('td') }), 4000);
						break;
					case 'answer':
						++this.data_model['page_' + report.page_id].answer_coms;
						$('div.tabs > ul > li', page).eq(2).find('div.new_items').html(
							Number(this.data_model['page_' + report.page_id].answers) +
							Number(this.data_model['page_' + report.page_id].answer_coms) + ' new')
							//console.log("call set time out for answer: " + report.target_id)
							setTimeout( function(){ update_embedded_discussion_links( this.td ); }.bind( { td: $('div#ans_' + report.target_id).closest('td') }), 4000);
						break;
				}
				break;
			case 'pub_com':
				++this.data_model['page_' + report.page_id].public_coms;
				++this.data_model.totals['page_' + report.page_id];
				$('div.tabs > ul > li', page).eq(3).find('div.new_items').html(this.data_model['page_' + report.page_id].public_coms + ' new')
				break;
			case 'bs_idea':
				++this.data_model['page_' + report.page_id].ideas;
				++this.data_model.totals['page_' + report.page_id];				
				$('div.tabs > ul > li', page).eq(1).find('div.new_items').html(
					Number(this.data_model['page_' + report.page_id].ideas) + 
					Number(this.data_model['page_' + report.page_id].idea_coms) + ' new')
				break;
			case 'answer':
				++this.data_model['page_' + report.page_id].answers
				++this.data_model.totals['page_' + report.page_id];
				$('div.tabs > ul > li', page).eq(2).find('div.new_items').html(
					Number(this.data_model['page_' + report.page_id].answers) +
					Number(this.data_model['page_' + report.page_id].answer_coms) + ' new')
				break;
			case 'chat':
				++this.data_model['page_' + report.page_id].chat_msgs;
				++this.data_model.totals['page_' + report.page_id];
				$('div#chat_' + report.page_id + ' span.new_items').html(this.data_model['page_' + report.page_id].chat_msgs + ' new');
				break;
			case 'presence':
				console.log("presence page.id: " + report.page_id + ", ape_code: " + report.ape_code);
				if( !this.data_model.member_page_ids[report.ape_code] && report.ape_code != member.ape_code ){
					if(report.page_id){
						console.log("Didn't know where this member was, and it is not me, I will announce myself")
						// I didn't have a record of this user, they may not know me as well, so I will re-announce my presence
						announce_page_presence();
					}
				}
				if(report.page_id){
					this.data_model.member_page_ids[report.ape_code] = report.page_id;
					// add this member to end of this.data_model.members_online, if not already in the array
					if( $.inArray( report.ape_code, this.data_model.members_online) == -1 ) this.data_model.members_online.push(report.ape_code)
				}else{
					delete this.data_model.member_page_ids[report.ape_code]
					// remove this member from this.data_model.members_online
					this.data_model.members_online = $.grep( this.data_model.members_online, 
						function(ape_code){
							return ape_code != report.ape_code || member.ape_code == report.ape_code ? true : false;
						}
					)
				}
				this.update_page_members();
				return;
				break;
		}
		this.update_page_activity(report.page_id);
  },
	update_page_members: function(){
		// create the Team members online array 
		if( !areArraysEqual(NOTIFIER.data_model.members_online, NOTIFIER.data_model.members_online_displayed) ){
			//console.log("update the team members online")
			mem_online = $('div#members_online');
			$('div.ape_user',mem_online).remove();
			var p_end = $('p.clear_both',mem_online);
			$.each( NOTIFIER.data_model.members_online,
				function(){
					var ape_code = this;
					//console.log("update_page_members online: add member to online: " + ape_code);
					var mem = $('div#team_members_roster div.ape_user[ape_code="' + ape_code + '"]')
					if(mem.size()>0){
						mem = mem.clone();
						mem.attr('create_count', 1 )
						mem.find('span').remove();
						p_end.before(mem)
						// add the cluetip to the member
						mem.attr({href:'#ape_user_online', rel: '#ape_user_online', title: 'Team member details'}).cluetip(
						  {local: true, 
						  hideLocal: true, 
						  cursor: 'pointer',
						  onActivate: NOTIFIER.report_member_details}
						);					
					}				
				}
			);
			NOTIFIER.data_model.members_online_displayed = NOTIFIER.data_model.members_online.slice()
		}		
		// iterate through the this.data_model.member_page_ids[report.ape_code] and create a hash of page_ids
		var page_member_counts = {};
		for ( var apeCode in NOTIFIER.data_model.member_page_ids){ 
			var page_id = NOTIFIER.data_model.member_page_ids[apeCode];
			//console.log("apeCode: " + apeCode + " = " + page_id)
			if(page_member_counts[page_id]){
				++page_member_counts[page_id]
			}else{
				page_member_counts[page_id] = 1;
			}
		};
		// update the team_members online display as necessary
		// did the list change?
		
		
		// iterate through each page and set the member_indicator sprite coordinates
		$('div.nav div.link').each(
			function(){
				var navbar = $(this);
				var page_id = Number(navbar.find('a').attr('href').match(/\d+/));
				var member_count = page_member_counts[page_id] || 0;
				NOTIFIER.data_model['page_' + page_id].members = member_count;
				var offset = member_count == 0 ? 0 : member_count > 10 ? -210 : -(member_count * 20 + 20);
				if(offset == 0){
					navbar.find('div.member_indicator').css({'display' : 'none'});
				}else{
					// I must manually set the x offset based on presesence of cur_nav_link class
					var offset = navbar.hasClass('cur_nav_link') ? '-40px ' + offset + 'px' : '0 ' + offset + 'px';
					navbar.find('div.member_indicator').css({'background-position' : offset, 'display' : 'block'});
				}				
			}
		)
	},
	update_page_activity: function(p_id){
		// update the specific element and then calculate for the activity indicator
		var page_id = 'page_' + p_id;
		//console.log("update_page_activity for page: " + page_id )
		temp.update_page_activity_this = this.data_model;
		//console.log("Total: " + this.data_model.totals[page_id]	)
		// for now just show 1 to 5 bars, or no bars, 1 bar per item up to 5
		var total = this.data_model.totals[page_id];
		var offset = total == 0 ? 0 : total > 4 ? -120 : -(total * 20 + 20);
		if(offset == 0){
			$('div.nav a[href$="' + p_id + '"]').parent().find('div.activity_indicator').css({'display' : 'none'});
		}else{
			$('div.nav a[href$="' + p_id + '"]').parent().find('div.activity_indicator').css({'background-position' : '0 ' + offset + 'px', 'display' : 'block'});			
		}
	},
  data_model: {ver: 1.0},
	report_page_presence: function(el){
		//console.log("report_page_presence")
	  $('.clue-tip-source').remove();
	  var page_id = Number( el.parent().find('a').attr('href').match(/\d+$/)); 
		//console.log("report_page_presence page_id: " + page_id);
	  if(NOTIFIER.data_model['page_' + page_id].members > 0){
	    //console.log("report_page_presence members > 0 page_id: " + page_id);
	    var page_roster = $('#team_members_roster').clone(true).removeAttr('id')
	    $('div.ape_user',page_roster).each(
	      function(){
	        if(NOTIFIER.data_model.member_page_ids[ this.getAttribute('ape_code') ] == page_id){
	          //console.log("keep this user")
	        }else{
	          //console.log("Remove this user")
	          $(this).remove();
	        }
	      }
	    )
	    page_roster.addClass('clue-tip-source').attr('id','page_presence_cluetip')
	    $('body').append(page_roster)
	    return true;
	  }else{
	    // No members to show
	    return false;
	  }
	},
	report_member_details: function(el){
		try{
		  $('.clue-tip-source').remove();
		  var ape_code = el.attr('ape_code'); 
			//console.log("ape_code: " + ape_code);
			var ape_user = $('div#team_members_roster div.ape_user[ape_code="' + ape_code + '"]').clone(true)
			var member_details = $('<div class="clue-tip-source" id="ape_user_online"></div>').append(ape_user)
			var page_id = NOTIFIER.data_model.member_page_ids[ ape_code ];
			if(page_id){
				//console.log("page_id: " + page_id)
				var page_link = $('div.nav a[href$=' + page_id + ']').clone(true).css('color','black')
				member_details.append($('<p>Currently in </p>').append(page_link));
			}
		  $('body').append(member_details)
		  return true;
		}catch(e){
			var member_details = $('<div class="clue-tip-source" id="ape_user_online"></div>').html('We apologize we cannot find this user right now');
			$('body').append(member_details);
			return true
		}		
	},
  init: function(){
    //console.log("initialize the notifier")
    //console.log("pages: " + $('div.Page').size() )
		data = this.data_model;
		data.totals = {};
		data.members_online = [];
		data.members_online_displayed = [];
		data.member_page_ids = {};
		// set up the data structure for each page
    $('div.Page').each(
      function(){
				var page_id = 'page_' + Number(this.id.match(/\d+/));
        data[page_id] = 
          { 
            team_coms: 0,
            public_coms: 0,
            ideas: 0,
            idea_coms: 0,
            answers: 0,
            answer_coms: 0,
            chat_msgs: 0,
            members: 0
          };
				data.totals[page_id] = 0;
      }
    )
		// now count all the new content on the page
		//console.log("# new_items: " + $('.new').size() )
		$('.new').each(
			function(){
				try{
					//console.log("process new item")
					var page_id = 'page_' + Number( $(this).closest('.Page').attr('id').match(/\d+/))
					//console.log("new iten page_id: " + page_id)
					switch(String(this.className.match(/_\w*/))){
						case '_comment':
							//console.log("_comment")
							// is this public or team comment?
							var disc = $(this).closest('div.discussion');
							if(disc.hasClass('public')){
								++data[page_id ].public_coms;
							}else{
								++data[page_id ].team_coms;
							}
							++data.totals[page_id]
							// is this also an embedded comment? does it, or an ancestor have a target_type != 0 
							// div.Comment_entry target_type = 2 || 11
							var el = $(this)
							var par = el.parent().closest('div.Comment_entry')

							while(par.size() > 0 ){
								var tgt_type = par.attr('target_type');
								//console.log("tgt_type: " + tgt_type)
								if(tgt_type && tgt_type == 2){
									//console.log("embedded answer com")
									++data[page_id ].answer_coms;
									break;
								}else if(tgt_type && tgt_type == 11){
									//console.log("embedded bs_idea com")
									++data[page_id ].idea_coms;
									break;
								}
								par = par.parent().closest('div.Comment_entry')
							};
    
							break;
						case '_bs_idea':
							//console.log("_bs_idea")
							++data[page_id ].ideas;
							++data.totals[page_id]
							break;
						case '_answer':
							//console.log("_answer")
							++data[page_id ].answers;
							++data.totals[page_id]
							break;
					}
				}catch(e){'ERROR init count new content e: ' + e}
			}
		)
		// finally, I want to display the counts and activity
		//var update_page_activity = this.update_page_activity;
		var data = this.data_model;
		$('div.Page').each(
      function(){
				var page = $(this);
				var p_id = Number(this.id.match(/\d+/));
				var page_id = 'page_' + p_id;
				//console.log("update page: " + page_id )
				if(data[page_id].team_coms > 0)$('div.tabs > ul > li', page).eq(0).find('div.new_items').html(data[page_id].team_coms + ' new')
				if(data[page_id].public_coms > 0)$('div.tabs > ul > li', page).eq(3).find('div.new_items').html(data[page_id].public_coms + ' new')
				if(Number(data[page_id].ideas) + Number(data[page_id].idea_coms) > 0)$('div.tabs > ul > li', page).eq(1).find('div.new_items').html(
					Number(data[page_id].ideas) + 
					Number(data[page_id].idea_coms) + ' new')
				if(	Number(data[page_id].answers) + Number(data[page_id].answer_coms) > 0 )$('div.tabs > ul > li', page).eq(2).find('div.new_items').html(
					Number(data[page_id].answers) +
					Number(data[page_id].answer_coms) + ' new')
				//$('div#chat_' + report.page_id + ' span.new_items').html(this.data_model['page_' + report.page_id].chat_msgs + ' new');
		
				//console.log("call update_page_activity")
				NOTIFIER.update_page_activity(p_id);
      }
    )
  }
}

/*

$.getScript('http://cgg.1civicevolution.org/javascripts/notifier.js?' + Math.round(Math.random()*100000))  

NOTIFIER.init()
NOTIFIER.data_model

NOTIFIER.inform( { type: 'bs_idea', page_id: 737 })
NOTIFIER.inform( { type: 'answer', page_id: 737 })
NOTIFIER.inform( { type: 'chat', page_id: 737 })
NOTIFIER.inform( { type: 'pub_com', page_id: 737 })
NOTIFIER.inform( { type: 'comment', page_id: 737 })
NOTIFIER.inform( { type: 'comment', page_id: 737, target_type: 'bs_idea' })
NOTIFIER.inform( { type: 'comment', page_id: 737, target_type: 'answer' })

		// report { type, id, page_id, [target_type, target_id]}  optional for idea and answer comments

I want to override last_visit
update activities set created_at = created_at - interval '3 days' where member_id = 1 and team_id = 10004;


$('div#members_online div.ape_user').cluetip('destroy');
$('div#members_online div.ape_user').cluetip(
  {local: true, 
  hideLocal: false, 
  cursor: 'pointer',
	sticky: true,
  onActivate: NOTIFIER.report_member_details}
);

el = $('div#team_members_roster div.ape_user:first')
NOTIFIER.report_member_details(el)
$('.clue-tip-source')

$('div#members_online div.ape_user').attr({href:'#ape_user_online', rel: '#ape_user_online', title: 'Team member details'})
$('div#members_online div.ape_user').cluetip('destroy');
$('div#members_online div.ape_user').cluetip(
  {local: true, 
  hideLocal: true, 
  cursor: 'pointer',
  onActivate: NOTIFIER.report_member_details}
);


*/
