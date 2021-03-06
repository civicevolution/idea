// js code for the theming page

//var project_coordinator = true;

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
				// insert and position the autoscroll hotspots
				$('<div class="auto-scroll top"></div>').appendTo(theme_cols_window).width(width).css({top: 0, left: left}).attr('id',this.id);
				$('<div class="auto-scroll bottom"></div>').appendTo(theme_cols_window).width(width).css({top: lower_hotpsot_top, left: left}).attr('id',this.id);
			}else{
				//adjust the position of existing ones
				$('div.auto-scroll.top[id="' + this.id +'"]').width(width).css({top: 0, left: left});
				$('div.auto-scroll.bottom[id="' + this.id +'"]').width(width).css({top: lower_hotpsot_top, left: left});
			}
		}
	);
		
	theme_cols_window.find('div.auto-scroll.left').height( theme_cols_window.height() - 48 ).css({top: win_top + 60, left: win_left});
	theme_cols_window.find('div.auto-scroll.right').height( theme_cols_window.height() - 48 ).css({top: win_top + 60, left: win_left + theme_cols_window.parent().width() - 24 });
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
var drag_mode_active = false;
function make_ideas_sortable(idea_lists_ul){
	if(editing_disabled(false))return false;
	var debug = false;
	idea_lists_ul.sortable({
		helper: 'clone',
		appendTo: 'body',
		items: 'li.idea_post_it:not(.placeholder)',
		connectWith: ".sortable_ideas",
		cursor: 'move',
		opacity: .8,
		cursorAt: {left: 0, top: 0},
		tolerance: 'pointer',
		start: function(event, ui) { 
			drag_mode_active = true;
			$('div.auto-scroll')
				.addClass('scroll-active')
				.bind('mouseleave', stopAutoScroll )
				.mousemove(function(e) {autoscroll_mousemove(e.pageX, e.pageY, this);});
			var list = $(this);
			var par = list.closest('div.theme_col');	
			if(debug) console.log("START sortable drag in col: " + par.attr('id')); 
		},
		stop: function(event, ui) { 
			if(debug) console.log("STOP sortable drag\n\n\n\n\n\n"); 
			stopAutoScroll();
			$('div.auto-scroll')
				.removeClass('scroll-active')
				.unbind('mousemove')
				.unbind('mouseleave');
			setTimeout( function(){drag_mode_active = false;}, 200);
		}, 
		over: function(event,ui){
			var list = $(this);
			list.addClass('highlight_dropzone');
			if(list.find('li.idea_post_it div.post-it').size() == 0){
				ui.placeholder.height(300);
			}else{
				ui.placeholder.height(100);			
			}
		},
		out: function(event,ui){
			var list = $(this);
			list.removeClass('highlight_dropzone');
		},
		update: function(event,ui){
			var list = $(this);
			var par = list.closest('div.theme_col');
			if(par.size() > 0){
				if(debug) console.log("sortable update for theme: " + par.attr('id') );
				if( par.attr('id') != 'placeholder'){
					var ordered_ids = $.makeArray(par.find('li.idea_post_it div.post-it').map(function(){return Number(this.id);}));
					if(debug) console.log("Update idea order, ordered_ids: " + ordered_ids );
					
					post_theme_changes({act: 'update_list_idea_ids', ltp_ids: ordered_ids, list_id: par.attr('id') });
					
					list.sortable('refresh');
				}else{
					// create a new answer group (theme)
					var idea = list.find('li.idea_post_it:visible').addClass('for_new_group').hide();
					temp.new_answer_group_idea = idea;
					var constituent_idea_id = idea.find('div.post-it').attr('id');
					if(debug) console.log("create a new answer group containing idea id: " + constituent_idea_id );
					
					post_theme_changes({act: 'new_list', idea_id: constituent_idea_id, output_tag: page_data.output_tag })
					
				}
			}
		}
	});
}

//$('body').on('mouseup', 'div.my_new_ideas div.post-it',
//	function(event){
//		if( event.target.className != 'delete' ){
//			//console.log("show_idea_details for this.id: " + this.id);
//			if(this.id > 0){
//				var url = '/idea/' + this.id + '/details?act=my_new_idea_popup';
//				if( event.target.className == 'edit' ){
//					url += '&mode=edit';
//				}
//				$.getScript(url);
//			}
//		}
//	}
//);
//
$('body').on('mouseup', 'div.theming_page li.theme_post_it div.post-it',
	function(event){
		if( event.target.className != 'delete' ){
			if(editing_disabled())return false;
			//console.log("show_idea_details for this.id: " + this.id);
			if( !drag_mode_active && this.id > 0){
				var url = '/theme/' + this.id + '/details?mode=edit';
				$.getScript(url);
			}
		}
	}
);

$('body').on('click','div.theming_page li.idea_post_it img.delete', 
	function(event){
		if(editing_disabled())return false;
		var post_it = $(this).closest('div.post-it');
		var list = post_it.closest('div.theme_col');
		console.log("remove idea " + post_it.attr('id') + " from list: " + list.attr('id') );
		post_theme_changes({act: 'delete_theme_child', list_id: list.attr('id'), idea_id: post_it.attr('id') });
		//$.post('/idea/' + post_it.attr('id') + '/remove_from_parent', 
		//	"script"
		//);
	}
);

$('body').on('click','div.theming_page li.theme_post_it img.delete',
	function(event){
		if(editing_disabled())return false;
		//console.log("delete this theme if no children");
		var theme = $(this).closest('div.post-it');
		if(theme.closest('ul.sortable_ideas').find('li.idea_post_it').size() == 0){
			console.log("delete this list now");
			post_theme_changes({act: 'delete_theme', list_id: theme.attr('id') });
			//$.post('/idea/' + theme.attr('id') + '/remove_theme', 
			//	"script"
			//);
		}else{
			alert('Sorry, you cannot delete a theme with ideas');
		}
	}
);

$('div.post-it div.star').live('click', 
  function(event) {
    if(editing_disabled())return false;
  	var idea = $(this).closest('div.post-it');
  	if(idea.hasClass('example')){
			$('div.post-it[id="' + idea.attr('id') + '"]').removeClass('example');
      //console.log("Clear idea as example for the theme/list")
  	}else{
			$('div.post-it[id="' + idea.attr('id') + '"]').addClass('example');
      //console.log("Save idea as example for the theme/list")
  	}
  	
  	var theme = idea.closest('div.theme_col');

  	// get the example ids for this list
    var example_ids = [];
    theme.find('div.post-it.example').each(
      function(){
        example_ids.push($(this).attr('id') );
      }
    );
	console.log("update_theme_examples, example_ids: " + example_ids + ", list_id: " + theme.attr('id') );
  	post_theme_changes({act: 'update_theme_examples', example_ids: example_ids, list_id: theme.attr('id')})
  	
  }
);

if(page_data.type == 'macro theming'){
	$('body').on('mouseenter', 'div.post-it div.examples',
		function(event){
			$(this).addClass('show')
		}
	);
	$('body').on('mouseleave', 'div.post-it',
		function(event){
			$(this).find('div.examples').removeClass('show')
		}
	);
}

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

//function show_and_highlight_postit(question_id, idea_id){
//	// is the question tabs for this question open?
//	var question_tabs = $('div.question_tabs[id="' + question_id + '"]');
//	var postit = question_tabs.find('div.post-it[id="' + idea_id + '"]');
//	if(question_tabs.size() == 0 || postit.size() == 0){
//		$.getScript('/idea/' + question_id + '/view?idea_id=' + idea_id );
//		return;
//	}
//	
//	var theme_col = postit.closest('div.theme_col');
//	
//	$('div.theme_cols_window_outer').scrollTo(theme_col,800);
//	theme_col.scrollTo(postit,800, 
//		function(){
//			postit.effect('highlight', {color: '#ff0000'},3000);
//		}
//	);
//}


//
// Set up theming page columns sortable
//

function make_theme_cols_sortable(page){
	//console.log("make_theme_cols_sortable");
	if(editing_disabled(false))return false;
	var debug = false;
	page.sortable({
		helper: 'clone',
		appendTo: 'body',
		items: 'div.theme_col.themes',
		cursor: 'move',
		opacity: .8,
		cursorAt: {left: 0, top: 0},
		tolerance: 'pointer',
		start: function(event, ui) { 
			$('div.auto-scroll.left, div.auto-scroll.right')
				.addClass('scroll-active')
				.bind('mouseleave', stopAutoScroll )
				.mousemove(function(e) {autoscroll_mousemove(e.pageX, e.pageY, this);});
		},
		stop: function(event, ui) { 
			if(debug) console.log("STOP sortable drag\n\n\n\n\n\n"); 
			stopAutoScroll();
			$('div.auto-scroll')
				.removeClass('scroll-active')
				.unbind('mousemove')
				.unbind('mouseleave');
			
			//console.log("update the theme sort order");
			var theme_cols_window = ui.item.closest('div.theme_cols_window');
			var new_ids = [];
			//var ltr_ctr = 1;
		 	theme_cols_window.find('div.theme_col').each( function(){
				var col = $(this);
				var id = col.attr('id');
				if( id.match(/^\d+$/) ){
					new_ids.push( id );
				}
			});
			new_ids = new_ids.join(',');
			// compare if the order has changed
			console.log("old order: " + theme_cols_window.attr('id_order') + " new order: " + new_ids);
			if( theme_cols_window.attr('id_order') != new_ids ){
				console.log("update the theme sort to: " + new_ids);
				post_theme_changes({act: 'reorder_lists', list_ids: $.makeArray($.map(new_ids.split(','), function(el){return Number(el)})) });
				//$.post('/idea/' + theme_cols_window.attr('id') + '/idea_order', 
				//	{	
				//		ordered_ids: $.makeArray($.map(new_ids.split(','), function(el){return Number(el)})),
				//		update_proposal: true
				//	}, 
				//	"script"
				//);
				//theme_edit_wait();
			}
		}, 
	});
}

function editing_disabled(show_msg_flag){
	show_msg_flag = (typeof show_msg_flag === "undefined") ? true : show_msg_flag;
	//if(!project_coordinator){
	if( disable_editing ){	
		if(show_msg_flag){
			alert("You are not authorized to edit");
		}
		return true;
	}else{
		return false;
	}
}

function theme_edit_wait(){
	var dialog = $('<p class="theme_saving_modal">Please wait a moment</p>').dialog( {title : 'Saving...', modal : true, width : '200px', closeOnEscape: true, close: function(){$(this).remove()} });
}
function clear_theme_edit_wait(){
	$('p.theme_saving_modal').closest('div.ui-dialog').dialog('destroy').remove();
}

$('body').on('change','div.theming_page p.visibility input[type="checkbox"]',
	function(){
		//console.log("adjust visibility");
		if(editing_disabled())return false;
		var checkbox = $(this);
		var visible = checkbox.attr('checked') == 'checked' || false;
		var id = Number(checkbox.attr('id').match(/\d+/));
		console.log("set " + id + " to visible: " + visible);
		
		post_theme_changes({act: 'update_theme_visibility', theme_id: id, visible: visible });
		//$.post('/idea/' + id + '/visbility', 
		//	{	
		//		visible: visible
		//	}, 
		//	"script"
		//);
		//theme_edit_wait();
	}
);

