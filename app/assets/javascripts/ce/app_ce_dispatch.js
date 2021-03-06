dispatcher = {
	_registry: {},
	register_listener: function(data_type, callback){
		if(!this._registry[data_type]) this._registry[data_type] = [];
		this._registry[data_type].push(callback)
	},
	dispatch: function(data_type,data){
		var callbacks = this._registry[data_type];
		$.each(callbacks,
			function(){
				this.call(dispatcher, data);
			}
		);
	},
	get_data: function(spec){
		switch( spec.type ){
			case 'question_comment_count':
				if(spec.new_only){
					return stat_data.comment_counts['question_new_' + spec.id ] || 0;
				}else{
					return stat_data.comment_counts['question_all_' + spec.id ] || 0;
				}
				break;
			case 'question_theme_count':
				if(spec.new_only){
					return stat_data.idea_counts['question_themes_new_' + spec.id ] || 0;
				}else{
					return stat_data.idea_counts['question_themes_all_' + spec.id ] || 0;
				}
				break;
			case 'question_idea_count':
				if(spec.new_only){
					return stat_data.idea_counts['question_ideas_new_' + spec.id ] || 0;
				}else if(spec.unrated_only){
					return stat_data.idea_counts['question_ideas_unrated_' + spec.id ] || 0;
				}else if(spec.unthemed_only){
					return stat_data.idea_counts['question_ideas_unthemed_' + spec.id ] || 0;
				}else{
					return stat_data.idea_counts['question_ideas_all_' + spec.id ] || 0;
				}
				break;
			case 'theme_idea_count':
				if(spec.new_only){
					return stat_data.idea_counts['theme_ideas_new_' + spec.id ] || 0;
				} else if(spec.unrated_only){
					return stat_data.idea_counts['theme_ideas_unrated_' + spec.id ] || 0;
				}else{
					return stat_data.idea_counts['theme_ideas_all_' + spec.id ] || 0;
				}
				break;
			case 'idea_comment_count':
				if(spec.new_only){
					return stat_data.comment_counts['idea_new_' + spec.id ] || 0;
				}else if(spec.combined_new_only){
					return (stat_data.comment_counts['idea_combined_new_' + spec.id ] || 0) + (stat_data.comment_counts['idea_new_' + spec.id ] || 0);
				}else if(spec.combined_only){
					return (stat_data.comment_counts['idea_combined_' + spec.id ] || 0 ) + ( stat_data.comment_counts['idea_all_' + spec.id ] || 0);
				}else if(spec.ideas_new_only){
					return stat_data.comment_counts['idea_combined_new_' + spec.id ] || 0;
				}else if(spec.ideas_only){
					return stat_data.comment_counts['idea_combined_' + spec.id ] || 0;
				}else{
					return stat_data.comment_counts['idea_all_' + spec.id ] || 0;
				}
				break;
		}
	},
	init_stat_comments_data: function(){
		// comments [id, question_id, parent_id, created_at]
		cstats = stat_data.comment_counts = {};
		cstats['total_all'] = 0;
		cstats['total_new'] = 0;
		stat_data['com_recs'] = {};
		for (var i=0, stat;(stat=stat_data.coms[i]);i++){
			stat_data['com_recs'][ stat[0] ] = stat;
			if(!stat[1]){stat[1] = 0} // team comments have no question id so set to 0
			++cstats['total_all'];
			// coms under question
			if(!cstats['question_all_' + stat[1] ] ){ cstats['question_all_' + stat[1] ] = 0};
			++cstats['question_all_' + stat[1] ];
			// new coms under idea
			if(!cstats['idea_all_' + stat[2] ] ){ cstats['idea_all_' + stat[2] ] = 0};
			++cstats['idea_all_' + stat[2] ];
			// now count new stuff
			if(stat[3] > stat_data.last_visit){	
				stat_data['com_recs'][ stat[0] ].new_com = true;
				// this is a new comment
				++cstats['total_new'];
				// new coms under question
				if(!cstats['question_new_' + stat[1] ] ){ cstats['question_new_' + stat[1] ] = 0};
				++cstats['question_new_' + stat[1] ];
				// new coms under idea
				if(!cstats['idea_new_' + stat[2] ] ){ cstats['idea_new_' + stat[2] ] = 0};
				++cstats['idea_new_' + stat[2] ];
			}
		}
	},
	init_stat_ideas_data: function(){
		// ideas [id, question_id, parent_id, role, created_at]
		istats = stat_data.idea_counts = {};
		istats['total_themes_all'] = 0;
		istats['total_themes_new'] = 0;
		istats['total_ideas_all'] = 0;
		istats['total_ideas_new'] = 0;
		stat_data['idea_recs'] = {};
		for (var i=0, stat;(stat=stat_data.ideas[i]);i++){
			stat_data['idea_recs'][ stat[0] ] = stat;
			if(stat[3] == 1){
				var idea_type = 'idea';
			}else if(stat[3] == 2){
				var idea_type = 'theme';
			}else{
				continue;
			}
			++istats['total_' + idea_type + 's_all'];
			// ideas under question 
			if(!istats['question_' + idea_type + 's_all_' + stat[1] ] ){ istats['question_' + idea_type + 's_all_' + stat[1] ] = 0};
			++istats['question_' + idea_type + 's_all_' + stat[1] ];
			// count unthemed ideas
			if(stat[2] == null && idea_type == 'idea'){
				if(!istats['question_' + idea_type + 's_unthemed_' + stat[1] ] ){ istats['question_' + idea_type + 's_unthemed_' + stat[1] ] = 0};
				++istats['question_' + idea_type + 's_unthemed_' + stat[1] ];
			}

			// now count new stuff
			if(stat[4] > stat_data.last_visit){
				// this is a new idea
				++istats['total_' + idea_type + 's_new'];
				// new ideas under question
				if(!istats['question_' + idea_type + 's_new_' + stat[1] ] ){ istats['question_' + idea_type + 's_new_' + stat[1] ] = 0};
				++istats['question_' + idea_type + 's_new_' + stat[1] ];
			}
			// ideas under theme 
			if(!istats['theme_' + idea_type + 's_all_' + stat[2] ] ){ istats['theme_' + idea_type + 's_all_' + stat[2] ] = 0};
			++istats['theme_' + idea_type + 's_all_' + stat[2] ];
			// now count new stuff
			if(stat[4] > stat_data.last_visit){
				// new ideas under theme
				if(!istats['theme_' + idea_type + 's_new_' + stat[2] ] ){ istats['theme_' + idea_type + 's_new_' + stat[2] ] = 0};
				++istats['theme_' + idea_type + 's_new_' + stat[2] ];
			}
		}
	},
	init_stat_ratings: function(){
		// iterate through the ratings
		// if member_id is not null, mark the idea as rated
		// idea_ratings [idea_id, member_id, rating]
		istats = stat_data.idea_ratings = {};
		istats.rated_ideas = [];
		for (var i=0, stat;(stat=stat_data.ratings[i]);i++){
			if(!istats['idea_' + stat[0] ] ){ istats['idea_' + stat[0] ] = []};
			istats['idea_' + stat[0] ].push( stat[2] );
			if(stat[1]){
				istats.rated_ideas.push( stat[0] );
				stat_data['idea_recs'][ stat[0] ].rated = true;
			}
		}
		if(stat_data.my_ratings){
			for (var i=0, stat;(stat=stat_data.my_ratings[i]);i++){
				istats.rated_ideas.push( stat[0] );
				stat_data['idea_recs'][ stat[0] ].rated = true;
				stat_data['idea_recs'][ stat[0] ].my_rating = stat[2];
			}
		}
		
	},
	init_stat_ideas_unrated_data: function(){
		// ideas [id, question_id, parent_id, role, created_at]
		istats = stat_data.idea_counts;
		istats['total_themes_unrated'] = 0;
		istats['total_ideas_unrated'] = 0;
		for (var i=0, stat;(stat=stat_data.ideas[i]);i++){

			if(stat[3] == 1){
				var idea_type = 'idea';
			}else if(stat[3] == 2){
				var idea_type = 'theme';
			}else{
				continue;
			}
			// ideas under question 
			// now count unrated ideas
			if(!stat_data.idea_recs[ stat[0] ]['rated']){
				// this is a unrated idea
				++istats['total_' + idea_type + 's_unrated'];
				// unrated ideas under question
				if(!istats['question_' + idea_type + 's_unrated_' + stat[1] ] ){ istats['question_' + idea_type + 's_unrated_' + stat[1] ] = 0};
				++istats['question_' + idea_type + 's_unrated_' + stat[1] ];
				// unrated ideas under theme
				if(!istats['theme_' + idea_type + 's_unrated_' + stat[2] ] ){ istats['theme_' + idea_type + 's_unrated_' + stat[2] ] = 0};
				++istats['theme_' + idea_type + 's_unrated_' + stat[2] ];
			}
		}
	},
	init_stat_theme_combined_comments_data: function(){
		var cstats = stat_data.comment_counts;
		// add all idea comment counts to the parent_id combined count
		// ideas [id, question_id, parent_id, role, created_at]
		for (var i=0, stat;(stat=stat_data.ideas[i]);i++){
			if(stat[3] != 1){
				continue;
			}
			// total coms under idea (role==1) parent
			if( cstats['idea_all_' + stat[0] ] > 0 ){
				if(!cstats['idea_combined_' + stat[2] ] ){ cstats['idea_combined_' + stat[2] ] = 0};
				cstats['idea_combined_' + stat[2] ] += cstats['idea_all_' + stat[0] ];
			}
			// new coms under idea (role==1) parent
			if( cstats['idea_new_' + stat[0] ] > 0 ){
				if(!cstats['idea_combined_new_' + stat[2] ] ){ cstats['idea_combined_new_' + stat[2] ] = 0};
				cstats['idea_combined_new_' + stat[2] ] += cstats['idea_new_' + stat[0] ];
			}
		}
	},
	update_question_stats: function(question_summaries){
		question_summaries = question_summaries || $('div.question_summary');
		//console.log("update_question_stats");
		question_summaries.each(
			function(){
				var question = $(this);
				var question_id = question.attr('id');
				var unrated_ideas = dispatcher.get_data( {type: 'question_idea_count', unrated_only: true, id: question_id});
				var unrated_link = question.find('div.idea-post-it-intro a.view_unrated_ideas');
				if(unrated_ideas == 0 || !member.signed_in){
					unrated_link.addClass('hide');
				}else{
					unrated_link.removeClass('hide').html( 'Rate ' + unrated_ideas + ' new idea' + (unrated_ideas != 1 ? 's' : '') );
				}
				var total_ideas = dispatcher.get_data( {type: 'question_idea_count', id: question_id});
				var has_answer = question.find('div.answer').size()>0;
				var summary_hdr = question.find('div.idea-post-it-intro');
				var view_ideas_link = summary_hdr.find('a.view_all_ideas');
				var unthemed_ideas = dispatcher.get_data( {type: 'question_idea_count', unthemed_only: true, id: question_id});
				if(project_coordinator && unthemed_ideas > 0){
					summary_hdr.find('span').html('');
					var str = "Organize " + unthemed_ideas + ' new idea' + (unthemed_ideas != 1 ? 's' : '')
					view_ideas_link.addClass('red').removeClass('hide').html( str );
				}
			}
		);	
	},
	update_discussion_stats: function(page){
		//console.log("update_discussion_stats");
		page = page || $('body');
		page.find('h4.discussion').each(
			function(){
				var header = $(this);
				var idea_id = header.attr('idea_id');
				var new_coms = dispatcher.get_data( {type: 'idea_comment_count', new_only: true, id: idea_id});
				var total_coms = dispatcher.get_data( {type: 'idea_comment_count', id: idea_id});
				var new_div = header.find('div.total').html(
					total_coms + ' total').end()
					.find('div.new').html( new_coms + ' new');
				if(new_coms == 0 ){new_div.addClass('hide');}else{new_div.removeClass('hide');}
				//if(total_coms == 0 ){ header.find('a span').html('Click to add a comment');}
			}
		);	
		page.find('h4.ideas_discussion').each(
			function(){
				var header = $(this);
				var idea_id = header.attr('idea_id');
				var new_coms = dispatcher.get_data( {type: 'idea_comment_count', ideas_new_only: true, id: idea_id});
				var new_div = header.find('div.total').html(
					dispatcher.get_data( {type: 'idea_comment_count', ideas_only: true, id: idea_id}) + ' total').end()
					.find('div.new').html( new_coms + ' new');
				if(new_coms == 0 ){new_div.addClass('hide');}else{new_div.removeClass('hide');}
			}
		);	
		
	},
	update_theme_stats: function(page){
		//console.log("update_theme_stats");
		page = page || $('body');
		if( page.hasClass('question_summary') ){
			var themes = page.find('li.theme');
		}else if( page.hasClass('theme') ){
			var themes = page;
		}else{
			var themes = page.find('div.question_summary li.theme');
		}
			
		themes.each(
			function(){
				var theme = $(this);
				var theme_id = theme.attr('id');
				theme.find('div.unrated').remove();
				if(!stat_data.idea_recs[theme_id].rated && member.signed_in){
					theme.find('div.comments').before('<div class="unrated">Rate this answer</span>');
				}

				var new_coms = dispatcher.get_data( {type: 'idea_comment_count', combined_new_only: true, id: theme_id});
				//console.log("theme_id: " + theme_id + " new_coms: " + new_coms );
				var new_div = theme.find('div.comments').find('div.total').html(
					dispatcher.get_data( {type: 'idea_comment_count', combined_only: true, id: theme_id}) + ' total').end()
					.find('div.new').html( new_coms + ' new');
				if(new_coms == 0){
					new_div.addClass('hide');
					theme.removeClass('show_new');
				}else{
					new_div.removeClass('hide');
					theme.addClass('show_new');
				}
			}
		);	
	},
	update_idea_stats: function(theming_page){
		//console.log("update_idea_stats");
		theming_page.find('div.post-it').each(
			function(){
				var post_it = $(this);
				var post_it_id = post_it.attr('id');
				var new_coms = dispatcher.get_data( {type: 'idea_comment_count', new_only: true, id: post_it_id});
				var total_coms = dispatcher.get_data( {type: 'idea_comment_count', id: post_it_id});
				if(total_coms == 0){
					post_it.find('div.comments').hide();
				}else{
					var new_div = post_it.find('div.comments').find('div.total').html( total_coms + ' total').end()
						.find('div.new').html( new_coms + ' new');
					if(new_coms == 0){new_div.addClass('hide');}else{new_div.removeClass('hide');}
				}
			}
		);	
	},
	update_coms_new: function(page){
		page = page || $('body');
		page.find('div.comment').each(
			function(){
				var comment = $(this);
				comment.removeClass('new');
				if( stat_data.com_recs[ comment.attr('id') ] && stat_data.com_recs[ comment.attr('id') ].new_com){ comment.addClass('new');}
			}
		);	
	},
	update_sliders: function(){
		$('div.ui-slider').each(
			function(){
				var slider = $(this);
				var id = slider.attr('id');
				var rating = stat_data.idea_recs[ id ].my_rating;
				if(rating){
					//console.log("rating for id: " + id  + " is " + rating);
					slider.slider('value',rating);
					var h4 = slider.closest('div.rater').prev('h4')
					h4.find('a').removeClass('hide');
					h4.find('span').html( h4.find('span').html().replace('Please rate','Your rating for') );
				}
			}
		);
	},
	init_stat_data: function(){
		if(typeof stat_data == 'undefined') return;
		dispatcher.init_stat_comments_data();
		dispatcher.init_stat_ideas_data();
		dispatcher.init_stat_ratings();	
		dispatcher.init_stat_ideas_unrated_data();	
		dispatcher.init_stat_theme_combined_comments_data();
		
		dispatcher.update_question_stats();
		dispatcher.update_theme_stats();
		dispatcher.update_discussion_stats();
	}
	
}

function dispatcher_test(data){
	//debugger
	console.log("dispatcher_test " + data);
}

//dispatcher.register_listener('color', dispatcher_test);
//
//dispatcher.dispatch('color', 'red');
//
//dispatcher.register_listener('color', function(data){
//	console.log("the data is " +  data);
//});
//

dispatcher.init_stat_data();
