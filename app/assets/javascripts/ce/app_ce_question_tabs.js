function init_question_tabs(question_view, page, idea_id){
	$('div.question_tabs').remove();
	$('body').append(question_view);
	$('div.page div.right_side ').fadeTo(300,0);
	
	// set div.page height to scrollTop + window height, which puts the question_view just below the window
	var scroll_x = $(window).scrollTop();
	var height = $(window).height();
	question_view.find('div#tabs-theming').height( height - question_view.find('div.theming_header').outerHeight() - 40 );
	var page = $('div.page');
	page.addClass('overflow_hidden');
	page.attr('last_scroll_pos',scroll_x)
	page.height( scroll_x + height );
	//console.log("scroll_x: " + scroll_x + ", height: " + height);
	// now animate the div.page till it gets to scrollTop thereby showing all of the question_view
	page.animate( { height: scroll_x}, 800,
		function(){
			// finally, put the div.page below the question view
			page.hide();
			$('html,body').scrollTop(0);
			page.height('auto');
			page.removeClass('overflow_hidden');
			question_view.after( $('div.page') );
			setTimeout(
				function(){
					init_question_view(this, idea_id);
					resize_theming_page();
					make_ideas_sortable( question_view.find('ul.sortable_ideas') );
					truncate_themes( question_view.find('div.theme_col li.theme_post_it div.post-it') );
				}.bind(question_view),100
			);
		}
	);
}
function init_question_view(question_view, idea_id){
	//console.log("init_question_view for id: " + question_view.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());
	$('div.tabs-theming').height( $(window).height() - $('div.theming_header').outerHeight() - 40 );
	
	$('<a href="#" class="close close_theming_page" id="' + question_view.attr('id') + '">Close</a>').appendTo( question_view.find('div.theming_header') );
	$('<a href="#" class="close_theming_page" id="' + question_view.attr('id') + '">Proposal page</a>').appendTo( question_view.find('li.idea_post_it div.post-it[id="-1"]') );
	
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('div.theming_page_outer ul.sortable_ideas'))}.bind(question_view),200);
	
	setTimeout(function(){make_theme_cols_sortable(this.find('div.theme_cols_window'))}.bind(question_view),250);
	
	
	//make_final_edit_themes_sortable( question_view.find('ul.themes') );
	
	activate_details(question_view);
	
	if(idea_id){
		setTimeout(function(){show_and_highlight_postit(question_view.attr('id'), idea_id);}, 100);
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