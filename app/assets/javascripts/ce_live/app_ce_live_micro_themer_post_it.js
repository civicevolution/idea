$(function() {
	init_post_its_theming_page();
});

function init_post_its_theming_page(){
	
	var post_its_wall = $('body').find('div.theming_page_outer');
	
	//set height
		post_its_wall.height( $(window).height() - 50 );
	//set width
		post_its_wall.width( $(window).width() );
		//post_its_wall.css({left: $(window).width(), top: $(window).scrollTop() });
	
	setTimeout(
		function(){
			init_post_its_wall(this);
			resize_theming_page();
			make_ideas_sortable( post_its_wall.find('ul.sortable_ideas') );
			truncate_themes( post_its_wall.find('div.theme_col li.theme_post_it div.post-it') );
			//dispatcher.update_idea_stats( post_its_wall );
			$('div.ui-slider').hide();
			//$('div.page').hide().attr('last-scroll-pos', $(window).scrollTop() );
			$('div.my_new_ideas').hide();
			//$(window).scrollTop(0);
			post_its_wall.css('top',0);
		}.bind(post_its_wall),100
	);
}
function init_post_its_wall(post_its_wall){
	//console.log("init_post_its_wall for id: " + post_its_wall.attr('id') );
	
	//console.log("set height $(window).height(): " + $(window).height() + ", $('ul.ui-tabs-nav').outerHeight(): " + $('ul.ui-tabs-nav').outerHeight());

	$('div.tabs-theming').height( $(window).height() - $('div.theming_header').outerHeight() - 40 );
		
	//console.log("settimeout for make_ideas_sortable");
	setTimeout(function(){make_ideas_sortable(this.find('ul.sortable_ideas'))}.bind(post_its_wall),200);
	
	setTimeout(function(){make_theme_cols_sortable(this.find('div.theme_cols_window'))}.bind(post_its_wall),250);
	
	activate_details(post_its_wall);
	
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

function activate_details(details){
	
	activate_text_counters_grow(details.find('textarea'), 120);
	//details.modal( {escClose: false});
	
	// set the width of the navigation area
	var max_markers = 1;
	details.find('div.navigation > div').each(
		function(){
			var cnt = $(this).find('> a').size();
			if(cnt>max_markers){max_markers = cnt}
		}
	);
	details.find('div.navigation').width( max_markers * 30);

	//init_rating_sliders( details.find("div.theme_slider") );
	
	//init_file_uploads( details.find('input.attachment-upload') );
}