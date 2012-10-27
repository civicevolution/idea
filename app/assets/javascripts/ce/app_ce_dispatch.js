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
				}else{
					return stat_data.idea_counts['question_ideas_all_' + spec.id ] || 0;
				}
				break;
			case 'theme_idea_count':
				if(spec.new_only){
					return stat_data.idea_counts['theme_ideas_new_' + spec.id ] || 0;
				}else{
					return stat_data.idea_counts['theme_ideas_all_' + spec.id ] || 0;
				}
				break;
			case 'idea_comment_count':
				if(spec.new_only){
					return stat_data.comment_counts['idea_new_' + spec.id ] || 0;
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
	},
	update_question_stats: function(){
		$('div.question_summary').each(
			function(){
				var question = $(this);
				var question_id = question.attr('id');
				var cta = question.find('div.call-to-action');
				cta.find('div.ideas').find('div.new').html(
					dispatcher.get_data( {type: 'question_idea_count', new_only: true, id: question_id}) + ' new').end().find('div.total').html(
					dispatcher.get_data( {type: 'question_idea_count', id: question_id}) + ' total');
				cta.find('div.themes').find('div.new').html(
					dispatcher.get_data( {type: 'question_theme_count', new_only: true, id: question_id}) + ' new').end().find('div.total').html(
					dispatcher.get_data( {type: 'question_theme_count', id: question_id}) + ' total');
				cta.find('div.comments').find('div.new').html(
					dispatcher.get_data( {type: 'question_comment_count', new_only: true, id: question_id}) + ' new').end().find('div.total').html(
					dispatcher.get_data( {type: 'question_comment_count', id: question_id}) + ' total');
			}
		);	
	},
	update_theme_stats: function(page){
		page = page || $('body');
		var themes = page.hasClass('question_summary') ? 
			page.find('li.theme') :
			page.find('div.question_summary li.theme');
		themes.each(
			function(){
				var theme = $(this);
				var theme_id = theme.attr('id');
				theme.find('div.ideas').find('div.new').html(
					dispatcher.get_data( {type: 'theme_idea_count', new_only: true, id: theme_id}) + ' new').end().find('div.total').html(
					dispatcher.get_data( {type: 'theme_idea_count', id: theme_id}) + ' total');
				theme.find('div.comments').find('div.new').html(
					dispatcher.get_data( {type: 'idea_comment_count', new_only: true, id: theme_id}) + ' new').end().find('div.total').html(
					dispatcher.get_data( {type: 'idea_comment_count', id: theme_id}) + ' total');
			}
		);	
	},
	update_idea_stats: function(theming_page){
		theming_page.find('div.post-it').each(
			function(){
				var post_it = $(this);
				var post_it_id = post_it.attr('id');
				var total_coms = dispatcher.get_data( {type: 'idea_comment_count', id: post_it_id});
				if(total_coms == 0){
					post_it.find('div.comments').hide();
				}else{
					post_it.find('div.comments').find('div.new').html(
						dispatcher.get_data( {type: 'idea_comment_count', new_only: true, id: post_it_id}) + ' new').end().find('div.total').html(
						total_coms + ' total');
				}
			}
		);	
	},
	init_stat_data: function(){
		if(typeof stats_data == 'undefined') return;
		dispatcher.init_stat_comments_data();
		dispatcher.init_stat_ideas_data();
		dispatcher.init_stat_ratings();	
		dispatcher.update_question_stats();
		dispatcher.update_theme_stats()
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


