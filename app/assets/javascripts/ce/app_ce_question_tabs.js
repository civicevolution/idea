function init_question_tabs(question_view, page){
	switch(page){
		case 'question':
			page = 0;
			break;
		case 'theming':
			page = 1;
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
	$('body').scrollTo(0,500);
	$('div.page').slideUp(800, function(){
		$('body').scrollTop(0);
		question_view.after( $('div.page') );
		setTimeout(function(){init_question_view(this);}.bind(question_view),300);
	})
	dispatcher.update_idea_stats(question_view);
}
function init_question_view(question_view){
	//console.log("init_question_view for id: " + question_view.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());
	$('div.ui-tabs-panel').height( $(window).height() - $('ul.ui-tabs-nav').outerHeight() - 40 );
	
	$('<a href="#" class="close" id="' + question_view.attr('id') + '">Close</a>').appendTo( question_view.find('ul.ui-tabs-nav') );
	
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('div.theming_page_outer ul.sortable_ideas'))}.bind(question_view),200);
	
	make_final_edit_themes_sortable( question_view.find('ul.themes') );
	
	activate_details(question_view);
}


$('body').on('click','ul.ui-tabs-nav a.close, div.theming_page a.close_theming_page, div.theme_final_edit a.close_theming_page', function(){
	var question_tabs = $(this).closest('div.question_tabs');
	var question_id = question_tabs.attr('id');
	var question = $('div.question_summary[id="' + question_id + '"]');
	$.getScript('/idea/' + question_id + '/theme_summary');
	$('div.page').show();
	question_tabs.slideUp(800, function(){
		question_tabs.remove();
		$('body').scrollTo(question, 300);
		$('div.page div.right_side ').fadeTo(300,1);
		}
	);
	return false;
});