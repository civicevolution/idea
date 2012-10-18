function init_question_tabs(question_view, page, idea_id){
	var open_theming_page = false;
	switch(page){
		case 'question':
			page = 0;
			break;
		case 'theming':
			// opening directly to theming tab causes an error, so do on a timeout
			page = 0;
			open_theming_page = true;
			break;
		case 'themes':
			page = 2;
			break;
		default:
			page = 0;
	}		
	question_view.find( "#tabs" ).tabs(
		{ 
			selected: page,
			show: function(event,ui){
				//console.log("show tab");
				if( $(ui.panel).attr('id') == 'tabs-theming'){
				 	resize_theming_page();
					make_ideas_sortable($(ui.panel).find('ul.sortable_ideas'));
				}
			}
		}
	);
	$('body').append(question_view);
	
	$('div.page div.right_side ').fadeTo(300,0);
	
	// set div.page height to scrollTop + window height, which puts the question_view just below the window
	var scroll_x = $(window).scrollTop();
	var height = $(window).height();
	question_view.find('div.ui-tabs-panel').height( height - question_view.find('ul.ui-tabs-nav').outerHeight() - 40 );
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
			setTimeout(function(){init_question_view(this, idea_id);}.bind(question_view),300);
			if(open_theming_page){
				setTimeout(function(){this.find('a[href="#tabs-theming"]').click();}.bind(question_view), 500);
			}
		}
	);
	dispatcher.update_idea_stats(question_view);
	dispatcher.update_theme_stats(question_view);
}
function init_question_view(question_view, idea_id){
	//console.log("init_question_view for id: " + question_view.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());
	$('div.ui-tabs-panel').height( $(window).height() - $('ul.ui-tabs-nav').outerHeight() - 40 );
	
	$('<a href="#" class="close" id="' + question_view.attr('id') + '">Close</a>').appendTo( question_view.find('ul.ui-tabs-nav') );
	
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('div.theming_page_outer ul.sortable_ideas'))}.bind(question_view),200);
	
	make_final_edit_themes_sortable( question_view.find('ul.themes') );
	
	activate_details(question_view);
	
	if(idea_id){
		setTimeout(function(){show_and_highlight_postit(question_view.attr('id'), idea_id);}, 100);
	}
	
}


$('body').on('click','ul.ui-tabs-nav a.close, div.theming_page a.close_theming_page, div.theme_final_edit a.close_theming_page', function(){
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