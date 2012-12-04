function init_question_post_its_wall(post_its_wall, question_id, idea_id){
	var prev_post_its_wall = $('div.question_tabs');
	var animate_duration = prev_post_its_wall.size() > 0 ? 0 : 800;
	$('body').append(post_its_wall);
	
	//set height
		post_its_wall.find('div.theming_page_outer').height( $(window).height() - 50 );
	//set width
		post_its_wall.width( $(window).width() );
		post_its_wall.css({left: $(window).width(), top: $(window).scrollTop() });
	
	setTimeout(
		function(){
			init_post_its_wall(this, question_id, idea_id);
			resize_theming_page();
			make_ideas_sortable( post_its_wall.find('ul.sortable_ideas') );
			truncate_themes( post_its_wall.find('div.theme_col li.theme_post_it div.post-it') );
			dispatcher.update_idea_stats( post_its_wall );
			$('div.ui-slider').hide();
			this.animate( {left: 0}, animate_duration,
				function(){
					$('div.page').hide().attr('last-scroll-pos', $(window).scrollTop() );
					$('div.my_new_ideas').hide();
					$(window).scrollTop(0);
					post_its_wall.css('top',0);
					prev_post_its_wall.remove();
				}
			);
		}.bind(post_its_wall),100
	);
}
function init_post_its_wall(post_its_wall, question_id, idea_id){
	//console.log("init_post_its_wall for id: " + post_its_wall.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());
	$('div.tabs-theming').height( $(window).height() - $('div.theming_header').outerHeight() - 40 );
	
	$('<a href="#" class="close close_theming_page" id="' + post_its_wall.attr('id') + '">Close</a>').appendTo( post_its_wall.find('div.theming_header') );
	$('<a href="#" class="close_theming_page" id="' + post_its_wall.attr('id') + '">Proposal page</a>').appendTo( post_its_wall.find('li.idea_post_it div.post-it[id="-1"]') );
	
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('div.theming_page_outer ul.sortable_ideas'))}.bind(post_its_wall),200);
	
	setTimeout(function(){make_theme_cols_sortable(this.find('div.theme_cols_window'))}.bind(post_its_wall),250);
	
	activate_details(post_its_wall);
	
	var wall = $('div.question_tabs');	
	var my_idea;
	$('div.my_new_ideas[id="' + question_id + '"] div.post-it').each(
		function(){
			my_idea = wall.find('div.post-it[id="' + this.id + '"]').effect('highlight', {color: '#ff0000'},3000);
		}
	);
	
	if(my_idea && my_idea.size() > 0){
		my_idea.eq(0).closest('div.theme_col').scrollTo(my_idea.eq(0),350);		
	}
}

function truncate_themes(post_its){
	// truncate long themes
	post_its.find('div.inner').each( 
		function(){
			var inner = $(this);
			inner.css('max-height','');
			if(inner.height() > 200){
				inner.css({overflow: 'hidden', 'max-height':'200px'}).append('<p class="more">More...</p>');
			}
		}
	);
}

$('body').on('click','div.theming_header a.close, div.theming_page a.close_theming_page', function(){
	var question_tabs = $(this).closest('div.question_tabs');
	var question_id = question_tabs.attr('id');
	$.getScript('/idea/' + question_id + '/theme_summary');
	question_tabs.animate( {left: question_tabs.width() }, 350, 
		function(){
			question_tabs.remove();
			$(window).scrollTop( $('div.page').show().attr('last-scroll-pos') );	
			$('div.my_new_ideas').show();		
			$('div.ui-slider').show();
		}
	);
	return false;
});
