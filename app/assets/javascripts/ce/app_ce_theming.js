// js code for the theming page

//
//resize code
//
function resize_theming_page(){
	var theme_cols_window = theming_page.find('div.theme_cols_window');
	theme_cols_window.height( $(window).height() - theme_cols_window.position().top - 100 );
	var theme_cols = theming_page.find('div.theme_col');
	var width = theme_cols.size() * ( theme_cols.eq(0).width() );
	var outer_win = theme_cols_window.parent();
	var max_width = outer_win.width() - outer_win.position().left;
	theme_cols_window.width( width > (max_width - 40) ? width : max_width );
	var win_top = theme_cols_window.position().top;
	var win_left = theme_cols_window.position().left;
	var win_bottom = win_top + theme_cols_window.height();
	$('div.theme_col').each(
		function(){
			var col = $(this);
			var left = col.position().left + win_left;
			var width = col.width();
			col.find('div.auto-scroll.top').width(width).css({top: win_top, left: left});
			col.find('div.auto-scroll.bottom').width(width).css({top: win_bottom - 24, left: left});
			col.find('div.new_group_drop_zone').css({top: win_top - 40, left: left + width - 60});
		}
	);
	theme_cols_window.find('div.auto-scroll.left').height( theme_cols_window.height() ).css({top: win_top, left: win_left});
	theme_cols_window.find('div.auto-scroll.right').height( theme_cols_window.height() ).css({top: win_top, left: win_left + theme_cols_window.parent().width() - 24 });
}

$('body').on( 'click', 'div.theming_page a.close_theming_page', 
	function(){
		var question = $('div.question_summary[id="' + this.id + '"]');
		$('div.page').show();
		theming_page.slideUp(800, function(){
			theming_page.remove();
			$('body').scrollTo(question, 300);
			$('div.page div.right_side ').fadeTo(300,1);
			}
		);
		return false;
	}
);


//
// Set up theming page sortable
//

var hideDropZonesTimeout = null;
function make_ideas_sortable(idea_lists_ul){
	idea_lists_ul.sortable({
		helper: 'clone',
		appendTo: 'body',
		items: 'li.idea_post_it',
		connectWith: ".sortable_ideas",
		start: function(event, ui) { 
			//console.log("Start sortable drag"); 
			$('div.auto-scroll')
				.bind('mouseleave', stopAutoScroll )
				.mousemove(function(e) {autoscroll_mousemove(e.pageX, e.pageY, this);});
			var list = $(this);
			var par = list.closest('div.theme_col');	
			showColumnDropZones(par);	
		},
		stop: function(event, ui) { 
			//console.log("stop sortable drag"); 
			stopAutoScroll();
			$('div.auto-scroll')
				.unbind('mousemove')
				.unbind('mouseleave');
			$('div.new_group_drop_zone').hide();	
		}, 
		over: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			if(list.parent().hasClass('new_group_drop_zone')){
				//console.log("cancel drop zone hide");
				clearTimeout(hideDropZonesTimeout);
				list.parent().addClass('drop_hover');
				ui.helper.addClass('drop_hover');
			}else{
				clearTimeout(hideDropZonesTimeout);
				$('div.new_group_drop_zone').hide();
				showColumnDropZones(par);
				list.addClass('highlight_dropzone');
			}
		
		},
		out: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			//console.log("sortable out " + par.attr('id') );
			if(list.parent().hasClass('new_group_drop_zone')){
				//console.log("Drop zone out, hide the drop zones now");
				$('div.new_group_drop_zone').removeClass('drop_hover').hide();
				if(ui.helper){ui.helper.removeClass('drop_hover');}
			}else{
				//console.log("Column out, hide the drop zones in 500 ms");
				list.removeClass('highlight_dropzone');
				hideDropZonesTimeout = setInterval( function(){ $('div.new_group_drop_zone').hide();}, 500);
			}
		
		},
		receive: function(event,ui){
			var list = $(this);
			if(list.parent().hasClass('new_group_drop_zone')){
				var par = list.closest('div.theme_col');
				createNewThemeGroup(ui, list, par);
			}
			//console.log("Hide the drop zones");
			$('div.new_group_drop_zone').hide();
		},
		update: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			console.log("sortable update for theme: " + par.attr('id') );
			temp['par' + par.attr('id')] = par
			//console.log("ordered_ids: " + par.find('li.idea_post_it div.post-it').map(function(){return this.id;}));
			// send the theme order data
			$.post('/idea/' + par.attr('id') + '/idea_order', 
				{	
					ordered_ids: $.makeArray(par.find('li.idea_post_it div.post-it').map(function(){return Number(this.id);}))
				}, 
				"script"
			);
		}
	});
}


function showColumnDropZones(par){
	//console.log("Show the dropzones for this this column: " + par.attr('id') );
	par.find('div.new_group_drop_zone').show();
	par.prev('div.theme_col').find('div.new_group_drop_zone').show();
}
function createNewThemeGroup(ui, list, par){
	var idea = list.find('li.idea_post_it').remove();
	console.log("createNewThemeGroup: Now create a new list for sortable receive " + par.attr('id') );
	
	// send the theme order data
	$.post('/idea/' + par.attr('id') + '/create_theme', 
		{	
			par_id: par.attr('id') ,
			child_idea_id: idea.find('div.post-it').attr('id') 
		}, 
		"script"
	);
	
	//realtime_data_update_functions['theme_col']( { data: { id: par.attr('id'), theme_idea: idea.find('p.idea').html() }, col_par: par });
}

$('body').on('mouseup', 'div.theming_page div.post-it', show_idea_details);
function show_idea_details(event){
	var edit_mode = $(this).closest('div.theme_col').hasClass('edit_mode');
	if( !edit_mode && !$(event.srcElement).is('img') ){
		console.log("show_idea_details for this.id: " + this.id);
		$.getScript('/idea/' + this.id + '/details');
	}
}

$('body').on('click','div.theming_page div.post-it img.delete', remove_idea_from_parent);
function remove_idea_from_parent(event){
	var post_it = $(this).closest('div.post-it');
	console.log("remove idea " + post_it.attr('id'));
	$.post('/idea/' + post_it.attr('id') + '/remove_from_parent', 
		"script"
	);
}

$('body').on('click','div.theming_page div.post-it img.edit',
	function(event){
		var theme_col = $(this).closest('div.theme_col').addClass('edit_mode');
		theme_col.find('ul.sortable_ideas').eq(1).sortable('disable');
		theme_col.find('textarea').autoGrow({
			minHeight  : 100,
			maxHeight : 500
		})
	}
);

//$('body').on('click','div.theming_page div.post-it img.clipboard',
//	function(event){
//		var post_it = $(this).closest('div.post-it');
//		console.log("copy text to clipboard: " + post_it.find('p.idea').html() );
//		//var theme = post_it.closest('div.theme_col')
//	}
//);

$('body').on('click','div.theming_page div.post-it a.cancel',
	function edit_theme(event){
		$(this).closest('div.theme_col').removeClass('edit_mode').find('ul.sortable_ideas').eq(1).sortable('enable');
	}
);




//
// Set up theming page auto scrolling with hotspots
//

var auto_scroll_params = { direction: 0, speed: 2, timer: 0, interval: 50, intervalTimer: null, scrollAxis: null };
function stopAutoScroll(){
	//console.log("Stop autoscrolling #########");
	clearInterval(auto_scroll_params.intervalTimer );
	auto_scroll_params.intervalTimer = null;
	auto_scroll_params.speed = 2;
	auto_scroll_params.direction = 0;
}

function autoscroll_mousemove(x, y, ctnr) {
	var ctnr = $(ctnr);
	//console.log("autoscroll_mousemove x: " + x + " y: " + y);
	// convert y to speed
	if( ctnr.hasClass('top') ){
		y = y - ctnr.offset().top;
		auto_scroll_params.direction = -1;
		speed = 24 - y;
		auto_scroll_params.scrollAxis = 'vertical';
		var scrollElement = ctnr.parent();
	}else if( ctnr.hasClass('bottom') ){
		y = y - ctnr.offset().top;
		auto_scroll_params.direction = 1;
		speed = y + 1;
		auto_scroll_params.scrollAxis = 'vertical';
		var scrollElement = ctnr.parent();
	}else if( ctnr.hasClass('left') ){
		x = x - ctnr.offset().left;
		auto_scroll_params.direction = -1;
		speed = 24 - x;
		auto_scroll_params.scrollAxis = 'horizontal';
		var scrollElement = ctnr.parent().parent();
	}else if( ctnr.hasClass('right') ){
		x = x - ctnr.offset().left;
		auto_scroll_params.direction = 1;
		speed = x + 1;
		auto_scroll_params.scrollAxis = 'horizontal';  
		var scrollElement = ctnr.parent().parent();
	}

	speed = Math.round( speed/2 );
	speed = speed < 2 ? 2 : speed;
	auto_scroll_params.speed = speed;
	if(!auto_scroll_params.intervalTimer){
	  auto_scroll_params.intervalTimer = setInterval( function(){autoScroll(this);}.bind(scrollElement), auto_scroll_params.interval);
	}
	//console.log("autoscroll_mousemove auto_scroll_params.direction: " + auto_scroll_params.direction + ", 	auto_scroll_params.speed: " + 	auto_scroll_params.speed);
}

function autoScroll(scrollElement) {
	if(auto_scroll_params.direction == 0){
		stopAutoScroll();
		return;
	}
	var scrollIncrement = auto_scroll_params.direction * auto_scroll_params.speed;
	//console.log("autoScroll with speed: " + auto_scroll_params.speed + " scrollIncrement: " + scrollIncrement);
	temp.scrollElement = scrollElement;
	temp.scrollIncrement = scrollIncrement
	if(auto_scroll_params.scrollAxis == 'vertical'){
		scrollElement.scrollTop( scrollElement.scrollTop() + scrollIncrement );
	}else{
		scrollElement.scrollLeft( scrollElement.scrollLeft() + scrollIncrement );
	}

}