function init_question_tabs(question_view){
	question_view.find( "#tabs" ).tabs(
		{ 
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


$('body').on('click','ul.ui-tabs-nav a.close', function(){
	var question = $('div.question_summary[id="' + this.id + '"]');
	$.getScript('/idea/' + this.id + '/theme_summary');
	$('div.page').show();
	var question_tabs = $('div.question_tabs[id="' + this.id + '"]');
	question_tabs.slideUp(800, function(){
		question_tabs.remove();
		$('body').scrollTo(question, 300);
		$('div.page div.right_side ').fadeTo(300,1);
		}
	);
	return false;
});