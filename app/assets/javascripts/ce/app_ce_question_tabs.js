function init_question_post_its_wall(post_its_wall, idea_id){
	$('div.question_tabs').remove();
	$('body').append(post_its_wall);
	$('div.page div.right_side ').fadeTo(300,0);
	
	// set div.page height to scrollTop + window height, which puts the post_its_wall just below the window
	var scroll_x = $(window).scrollTop();
	var height = $(window).height();
	post_its_wall.find('div#tabs-theming').height( height - post_its_wall.find('div.theming_header').outerHeight() - 40 );
	var page = $('div.page');
	page.addClass('overflow_hidden');
	page.attr('last_scroll_pos',scroll_x)
	page.height( scroll_x + height );
	//console.log("scroll_x: " + scroll_x + ", height: " + height);
	// now animate the div.page till it gets to scrollTop thereby showing all of the post_its_wall
	page.animate( { height: scroll_x}, 800,
		function(){
			// finally, put the div.page below the question view
			page.hide();
			$('html,body').scrollTop(0);
			page.height('auto');
			page.removeClass('overflow_hidden');
			post_its_wall.after( $('div.page') );
			setTimeout(
				function(){
					init_post_its_wall(this, idea_id);
					resize_theming_page();
					make_ideas_sortable( post_its_wall.find('ul.sortable_ideas') );
					truncate_themes( post_its_wall.find('div.theme_col li.theme_post_it div.post-it') );
				}.bind(post_its_wall),100
			);
		}
	);
}
function init_post_its_wall(post_its_wall, idea_id){
	//console.log("init_post_its_wall for id: " + post_its_wall.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());
	$('div.tabs-theming').height( $(window).height() - $('div.theming_header').outerHeight() - 40 );
	
	$('<a href="#" class="close close_theming_page" id="' + post_its_wall.attr('id') + '">Close</a>').appendTo( post_its_wall.find('div.theming_header') );
	$('<a href="#" class="close_theming_page" id="' + post_its_wall.attr('id') + '">Proposal page</a>').appendTo( post_its_wall.find('li.idea_post_it div.post-it[id="-1"]') );
	
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('div.theming_page_outer ul.sortable_ideas'))}.bind(post_its_wall),200);
	
	setTimeout(function(){make_theme_cols_sortable(this.find('div.theme_cols_window'))}.bind(post_its_wall),250);
	
	
	//make_final_edit_themes_sortable( post_its_wall.find('ul.themes') );
	
	activate_details(post_its_wall);
	
	if(idea_id){
		setTimeout(function(){show_and_highlight_postit(post_its_wall.attr('id'), idea_id);}, 100);
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
	$('div.page').show();
	question_tabs.slideUp(800, function(){
		question_tabs.remove();
		$('html,body').animate({scrollTop: $('div.page').attr('last_scroll_pos')}, 400);
		$('div.page div.right_side ').fadeTo(300,1);
		}
	);
	return false;
});