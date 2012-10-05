// js code for the theming page

//
//resize code
//
function resize_theming_page(){
	//console.log("\n\nresize_theming_page\n\n");
	var theming_height = $('div.theming_page_outer').height();
	//console.log("resize_theming_page to height: " + theming_height );
	var theming_page = $('div.theming_page');
	var theme_cols_window = theming_page.find('div.theme_cols_window');
	theme_cols_window.height( theming_height - 10 );
	
	var theme_cols = theming_page.find('div.theme_col');
	theme_cols.height( theming_height - 8 );
	var width = theme_cols.size() * ( theme_cols.eq(0).width() );
	var outer_win = theme_cols_window.parent();
	var max_width = outer_win.width() - outer_win.position().left;
	theme_cols_window.width( width > (max_width - 40) ? width : max_width );
	var win_top = theme_cols_window.position().top;
	var win_left = theme_cols_window.position().left;
	var lower_hotpsot_top = theme_cols_window.height() - 24;
	
	$('div.theme_col').each(
		function(){
			var col = $(this);
			var left = col.position().left;
			var width = col.width();
			if( $('div.auto-scroll[id="' + this.id +'"]').size() == 0 ){ // only insert once to the same theming page	
				//console.log("insert new drop zone and hotspots for " + this.id );
				// insert and position the autoscroll hotspots
				$('<div class="auto-scroll top"></div>').appendTo(theme_cols_window).width(width).css({top: 0, left: left}).attr('id',this.id);
				$('<div class="auto-scroll bottom"></div>').appendTo(theme_cols_window).width(width).css({top: lower_hotpsot_top, left: left}).attr('id',this.id);

				// insert and position the new group dropzones
				if(this.id != 'parked_ideas'){
					if(this.id != 'unthemed_ideas'){
						$('<div class="new_group_drop_zone left"><ul class="sortable_ideas"></ul></div>').appendTo(theme_cols_window)
							.css({top: 0, left: left}).attr('id',this.id);
					}
					$('<div class="new_group_drop_zone right"><ul class="sortable_ideas"></ul></div>').appendTo(theme_cols_window)
						.css({top: 0, left: left + width - 83}).attr('id',this.id);
				}
			}else{
				//adjust the position of existing ones
				$('div.auto-scroll.top[id="' + this.id +'"]').width(width).css({top: 0, left: left});
				$('div.auto-scroll.bottom[id="' + this.id +'"]').width(width).css({top: lower_hotpsot_top, left: left});
				$('div.new_group_drop_zone.left[id="' + this.id +'"]').css({top: 0, left: left});
				$('div.new_group_drop_zone.right[id="' + this.id +'"]').css({top: 0, left: left + width - 83});
			}
		}
	);
		
	theme_cols_window.find('div.auto-scroll.left').height( theme_cols_window.height() ).css({top: win_top, left: win_left});
	theme_cols_window.find('div.auto-scroll.right').height( theme_cols_window.height() ).css({top: win_top, left: win_left + theme_cols_window.parent().width() - 24 });
	//setTimeout(resize_dims, 1000);
}


function resize_dims(){
	console.log("$('div.theming_page_outer').height(): " + $('div.theming_page_outer').height());
	console.log("$('div.theming_page').height(): " + $('div.theming_page').height());
	console.log("$('div.theme_cols_window_outer').height():" + $('div.theme_cols_window_outer').height());
	console.log("$('div.theme_cols_window').height(): " + $('div.theme_cols_window').height());
	console.log("$('div.theme_col').height(): " + $('div.theme_col').height());
}


//
// Set up theming page sortable
//

var hideDropZonesTimeout = null;
function make_ideas_sortable(idea_lists_ul){
	if(editing_disabled(false))return false;
	var debug = false;
	idea_lists_ul.sortable({
		helper: 'clone',
		appendTo: 'body',
		items: 'li.idea_post_it',
		connectWith: ".sortable_ideas",
		cursor: 'move',
		opacity: .8,
		cursorAt: {left: 0, top: 0},
		tolerance: 'pointer',
		start: function(event, ui) { 
			$('div.auto-scroll')
				.bind('mouseleave', stopAutoScroll )
				.mousemove(function(e) {autoscroll_mousemove(e.pageX, e.pageY, this);});
			var list = $(this);
			var par = list.closest('div.theme_col');	
			if(debug) console.log("START sortable drag in col: " + par.attr('id')); 
			setTimeout(function(){showColumnDropZones(this);}.bind(par), 200);	
		},
		stop: function(event, ui) { 
			if(debug) console.log("STOP sortable drag\n\n\n\n\n\n"); 
			stopAutoScroll();
			$('div.auto-scroll')
				.unbind('mousemove')
				.unbind('mouseleave');
			$('div.new_group_drop_zone').removeClass('drop_hover').hide();	
		}, 
		over: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			if(list.parent().hasClass('new_group_drop_zone')){
				if(debug) console.log("OVER sortable with new_group_drop_zone hide and show for id: " + list.parent().attr('id') + ', class: ' + list.parent().attr('class'));
				//if(debug) console.log("cancel drop zone hide with id: " + list.parent().attr('id'));
				clearTimeout(hideDropZonesTimeout);
				list.parent().addClass('drop_hover');
				ui.helper.addClass('drop_hover');
				setTimeout(function(){$('ul.sortable_ideas').sortable('refresh');}, 100);
				setTimeout(function(){$('ul.sortable_ideas').sortable('refreshPositions');}, 200);
				
			}else{
				if(debug) console.log("OVER sortable NOT new_group_drop_zone, hide the call to showColumnDropZones for id: " + list.parent().attr('id') + ', class: ' + list.parent().attr('class'));
				clearTimeout(hideDropZonesTimeout);
				//$('div.new_group_drop_zone').hide();
				showColumnDropZones(par);
				list.addClass('highlight_dropzone');
			}
		
		},
		out: function(event,ui){
			var list = $(this);
			if(list.parent().hasClass('new_group_drop_zone')){
				par = list.parent();
				if(debug) console.log("OUT sortable has new_group_drop_zone REMOVE HOVER DO NOT HIDE for list: " + par.attr('id') + ', class: ' + par.attr('class') );
				$('div.new_group_drop_zone').removeClass('drop_hover');
				if(ui.helper){ui.helper.removeClass('drop_hover');}
				setTimeout(function(){$('ul.sortable_ideas').sortable('refresh');}, 100);
				setTimeout(function(){$('ul.sortable_ideas').sortable('refreshPositions');}, 200);
			}else{
				var par = list.closest('div.theme_col');
				if(debug) console.log("OUT sortable NOT new_group_drop_zone hide in 500 for list: " + par.attr('id') + ', class: ' + par.attr('class') );
				list.removeClass('highlight_dropzone');
				//hideDropZonesTimeout = setTimeout( function(){ $('div.new_group_drop_zone').hide();}, 500);
			}
			if(debug) console.log("sortable out COMPLETE " + par.attr('id') );
		},
		receive: function(event,ui){
			var list = $(this);
			if(debug) console.log("RECEIVE sortable id: " + list.parent().attr('id') + ', class: ' + list.parent().attr('class'));
			if(list.parent().hasClass('new_group_drop_zone')){
				if(list.parent().hasClass('drop_hover')){
					var par = $('div.theme_col[id="' + list.parent().attr('id') + '"]');
					createNewThemeGroup(ui, list, par);
				}else{
					if(debug) console.log("CANCEL RECEIVE b/c no hover, sortable id: " + list.parent().attr('id') + ', class: ' + list.parent().attr('class'));
					$('ul.sortable_ideas').sortable('cancel');
				}
			}else{
				if( !list.hasClass('highlight_dropzone')){
					$('ul.sortable_ideas').sortable('cancel');
				}
			}
			
			//if(debug) console.log("Hide the drop zones");
			$('div.new_group_drop_zone').removeClass('drop_hover').hide();
		},
		update: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			if(par.size() > 0){
				//if(debug) console.log("sortable update for theme: " + par.attr('id') );
				temp['par' + par.attr('id')] = par
				//if(debug) console.log("ordered_ids: " + par.find('li.idea_post_it div.post-it').map(function(){return this.id;}));
				// send the theme order data
				$.post('/idea/' + par.attr('id') + '/idea_order', 
					{	
						ordered_ids: $.makeArray(par.find('li.idea_post_it div.post-it').map(function(){return Number(this.id);}))
					}, 
					"script"
				);
			}
		}
	});
}


function showColumnDropZones(par){
	console.log("Show the dropzones for this this column: " + par.attr('id') );
	$('div.new_group_drop_zone').removeClass('drop_hover').hide();	
	$('div.new_group_drop_zone[id="' + par.attr('id') + '"]').show();
	//setTimeout(function(){this.find('ul.sortable_ideas').sortable('refresh');}.bind(par);
	par.find('ul.sortable_ideas').sortable('refresh');
}

function createNewThemeGroup(ui, list, par){
	if(editing_disabled())return false;
	var idea = list.find('li.idea_post_it').remove();
	//console.log("createNewThemeGroup: Now create a new list for sortable receive " + par.attr('id') );
	
	// send the theme order data
	$.post('/idea/' + par.attr('id') + '/create_theme', 
		{	
			par_id: par.attr('id'),
			side: (list.parent().hasClass('right') ? 'right' : 'left' ),
			child_idea_id: idea.find('div.post-it').attr('id') 
		}, 
		"script"
	);
	
	//realtime_data_update_functions['theme_col']( { data: { id: par.attr('id'), theme_idea: idea.find('p.idea').html() }, col_par: par });
}

$('body').on('mouseup', 'div.theming_page div.post-it', show_idea_details);
function show_idea_details(event){
	var edit_mode = $(this).closest('div.theme_col').hasClass('edit_mode');
	if( !edit_mode && !($(event.srcElement).is('img.delete') || $(event.srcElement).is('img.edit')) ){
		//console.log("show_idea_details for this.id: " + this.id);
		$.getScript('/idea/' + this.id + '/details');
	}
}

$('body').on('click','div.theming_page li.idea_post_it img.delete', 
	function(event){
		if(editing_disabled())return false;
		var post_it = $(this).closest('div.post-it');
		//console.log("remove idea " + post_it.attr('id'));
		$.post('/idea/' + post_it.attr('id') + '/remove_from_parent', 
			"script"
		);
	}
);

$('body').on('click','div.theming_page li.theme_post_it img.edit',
	function(event){
		if(editing_disabled())return false;
		var theme_col = $(this).closest('div.theme_col').addClass('edit_mode');
		theme_col.find('ul.sortable_ideas').sortable('disable');
		theme_col.find('textarea').autoGrow({
			minHeight  : 100,
			maxHeight : 500
		})
	}
);

$('body').on('click','div.theming_page li.theme_post_it img.delete',
	function(event){
		if(editing_disabled())return false;
		//console.log("delete this theme if no children");
		var theme = $(this).closest('div.post-it');
		if(theme.closest('ul.sortable_ideas').find('li.idea_post_it').size() == 0){
			//console.log("delete this list now");
			$.post('/idea/' + theme.attr('id') + '/remove_theme', 
				"script"
			);
		}else{
			alert('Sorry, you cannot delete a theme with ideas');
		}
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
		var post_it = $(this).closest('div.post-it');
		post_it.find('textarea').val( post_it.find('p.idea').html() );
		$(this).closest('div.theme_col').removeClass('edit_mode').find('ul.sortable_ideas').sortable('enable');
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
		var scrollElement = $('div.theme_col[id="' + ctnr.attr('id') + '"]');
	}else if( ctnr.hasClass('bottom') ){
		y = y - ctnr.offset().top;
		auto_scroll_params.direction = 1;
		speed = y + 1;
		auto_scroll_params.scrollAxis = 'vertical';
		var scrollElement = $('div.theme_col[id="' + ctnr.attr('id') + '"]');
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
	if(auto_scroll_params.scrollAxis == 'vertical'){
		scrollElement.scrollTop( scrollElement.scrollTop() + scrollIncrement );
	}else{
		scrollElement.scrollLeft( scrollElement.scrollLeft() + scrollIncrement );
	}

}

