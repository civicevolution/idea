//console.log("Loading app_ce_live_themer.js")
function live_resize(){
  if(adjust_in_process){
		setTimeout(adjust_columns, 1000);
		return;
	}
	
	// get overall avl height

	var win_height = $(window).height();
	if($('div#themer').size() > 0){
	  var ws = $('div.workspace');
	  ws.height( win_height - ws.position().top - 20);
	  
  	var tpdi = $('div.incoming_ideas');
  	tpdi.height(ws.height() - 4);
  	var h3_height = tpdi.find('h3').outerHeight(true);
  	var ltp = $('div#live_talking_points');
	  ltp.height(tpdi.height() - h3_height - 10);
	  var inner_padding = 20;
	  ltp.find('div.inner').height( ltp.height() - 4 - inner_padding);
	  
  	var lists = $('div.lists');
  	lists.height(ws.height() - 4);
  	//lists.height(ws.height() - 214);
  	var h3_height = lists.find('h3').outerHeight(true);
  	var lists_ws = $('div#lists');
	  lists_ws.height(lists.height() - h3_height - 10);
	  //var inner_padding = 20;
	  //ltp.find('div.inner').height( ltp.height() - 4 - inner_padding);
	  
	  // adjust widths
	  var list_col_width = $('div.list_column').width();
	  var num_cols = $('div.list_column').size();
	  var lists_width = num_cols * list_col_width;
	  lists_width = lists_width < $('div.drop_ribbon').width() ? $('div.drop_ribbon').width() : lists_width;
	  var avl_width = ws.width() - 20;
	  var incoming_width = avl_width - lists_width;
	  incoming_width = incoming_width > 800 ? 800 : incoming_width;
	  $('div.incoming_ideas').width( incoming_width);
	  //lists.width( ws.width() - lists.position().left - 10 )
	  //console.log("call adjust_columns from live_resize")
	  adjust_columns();
	}
}

setTimeout(live_resize,100);

$(window).resize(function(){
		try{  
			setTimeout(live_resize,800);
		}catch(e){}
	}
);

function fix_list_overflow(list){
	if(list.find('div.ideas').outerHeight() + list.find('div.header').outerHeight() > list.height()){
		//console.log("Collapse the list to make it fit");
		try{
		  var line_height = parseInt(list.find('p.text:first').css('line-height'));
		}catch(e){var line_height = 16;}
		var allotted_height = 4 * line_height;
		var all_ideas = list.find('div.idea');
		var vis_ideas = all_ideas.filter(':lt(3)')
		vis_ideas.each(
		  function(){
		    var idea = $(this);
		    if(idea.height() > allotted_height){
		      idea.height(allotted_height);
		    }
		  }
		);
		all_ideas.not(vis_ideas).hide();
	}
}

function expand_idea_list(list){
  return; 
  
  //console.log("expand_idea_list for " + list.find('p.theme').html() )
  if( $('div.idea_list.expanded').size() > 0)return;
  if(list.hasClass('misc_list') && dragging_new_idea ) return;
  
  var place_holder = $('<div class="idea_list_placeholder idea_list"></div>');
  place_holder.height(idea_list_height-2);
  place_holder.width(list.width()-2);
  var list_pos = list.position();
  list.css('left',list_pos.left);
  list.css('top',list_pos.top)
  //list.css('top',$('div.lists').offset().top)
  //list.css('top',0)
  list.addClass('expanded');
  list.after(place_holder);
  list.find('div.idea').show().height('auto');
  list.height('auto');
  if(list.hasClass('misc_list')){
    list.find('p.instr').hide();
  }
}


no_collapse = false;
function collapse_idea_list(list){
  return;
  if(no_collapse) return;
  //console.log("collapse_idea_list for " + list.find('p.theme').html() )
  $('div.idea_list_placeholder').remove();
  list.removeClass('expanded');  
  //console.log("collapse_idea_list set height to list_height: " + idea_list_height);
  //list.height(idea_list_height);
  fix_list_overflow(list);
  //console.log("call adjust_columns from collapse_idea_list")
  //setTimeout(adjust_columns,400);
  if(list.hasClass('misc_list')){
    list.find('p.instr').show();
    list.find('div.idea').hide();
  }
}

// make the lists fit in the display
var idea_list_height = 0;
//function adjust_lists(){
//  return
//  var lists_div = $('div#lists');
//  lists_div.find('div.idea_list.expanded').removeClass('expanded');
//  var idea_lists = lists_div.find('div.idea_list').not('div.idea_list.expanded');
//  // how many lists in a row?
//  var cur_top = 0;
//  var col_ctr = 0;
//  idea_lists.each( 
//    function(){
//      var top = $(this).offset().top;
//      if(cur_top == 0) cur_top = top;
//      if(cur_top == top){
//        ++col_ctr
//      }else{
//        return;
//      }
//    }
//  );
//  var num_rows = Math.ceil(idea_lists.size() / col_ctr);
//  var row_height = lists_div.height() / num_rows;
//  idea_list_height = row_height - 40;
//  idea_list_height = 220;
//  idea_lists.not('div.idea_list.misc_list').height(idea_list_height);
//  console.log("adjust_lists to set height to idea_list_height: " + idea_list_height);
//  idea_lists.each( 
//    function(){
//      setTimeout( function(){ fix_list_overflow( this )}.bind($(this)), 100);
//    }
//  );
//}

$('span.role').before( $('a.test_mode') );
$('div.test_mode :submit').live('click',
	function(){
		setTimeout( "$('div.test_mode').hide(1500)", 1000 )
		//console.log("hide form")
	}
);
$('a.test_mode').live('click',
	function(){
		var test = $('div.test_mode');
		if(test.is(':visible')){
			test.hide();
		}else{
			test.show();
			var pos = $(this).position();
			test.css({left: pos.left, top: pos.top + 20})
		}
		temp.this = $(this);
		temp.test = test;
		return false;
	}
)

var idea_list_ctr = 1;

function copy_idea_back_to_source(){
  if(confirm('Do you want to copy this idea, or move it?')){
    console.log("copy_idea_back_to_source");
    if( sort_start['prev_idea'].size() > 0 ){
      sort_start['prev_idea'].after(sort_start['item'].clone());
    }else{
      sort_start['idea_list'].find('div.ideas').prepend(sort_start['item'].clone());
    }
    sort_start = {};
  }
}
$('div.move_or_copy_idea button').die('click').live('click',
  function(){
    var btn = $(this);
    var div = btn.closest('div.move_or_copy_idea');
    var idea = div.next('.idea');
    idea.css('background-color','');
    if(btn.html().match(/move/i)){
      console.log("Move the idea");
    }else{
      console.log("copy_idea_back_to_source");
      var prev_idea = idea.data('prev_idea');
      if( prev_idea.size() > 0 ){
        prev_idea.after(idea.clone());
      }else{
        idea.data('source_list').find('div.ideas').prepend(idea.clone());
      }
    }
    idea.data('prev_idea');
    idea.data('source_list');     
    div.remove();
  }
);

// Sort the ideas within a list
function make_idea_lists_sortable($idea_lists){
  //console.log("make_idea_lists_sortable for " + $idea_lists.size() )
  $idea_lists.sortable(
  	{
  		start: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
  		  expand_idea_list(idea_list);
  		  //console.log("1 LIST idea_list sortable start " + theme); 
  		  if( !ui.item.hasClass('live_talking_point') ){
  		    ui.item.data('source_list', idea_list );
  		    ui.item.data('prev_idea', ui.item.prev('.idea') );
  		  }
  		  if(idea_list.hasClass('misc_list')){
  		    idea_list.find('p.instr').hide();
  		  }
  		},
  		out: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  if(idea_list.hasClass('misc_list')){
  		    idea_list.find('p.instr').show();
  		  }
  		},
  		stop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
  		  //console.log("1 LIST idea_list sortable stop " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
    		  ui.item.removeClass('live_talking_point ui-draggable');
          ui.item.addClass('idea');
        }
  			//update_curated_tp_ids( $(this) );
  			if( idea_list.find('div.idea').size() == 0 ){
  			  idea_list.find('div.ideas').html(
  			    '<a href="#" class="remove_list">Remove empty list</a>');
  			}else{
  			  idea_list.find('a.remove_list').remove();
  			}
  			if(idea_list.hasClass('misc_list')){
  			  ui.item.hide(600, function(){$(this).closest('div.idea_list').find('p.instr').show(600);});
  			  //ui.item.hide(600);
  			}
  			setTimeout( function(){ fix_list_overflow( this )}.bind(idea_list), 100);
  		},
  		drop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
    		var theme = idea_list.find('p.theme').html();
    		//console.log("1 LIST idea_list sortable drop " + theme);
    		
        $(this).append($(ui.helper).clone());
  		},
  		remove: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
    		var theme = idea_list.find('p.theme').html();
    		//console.log("1 LIST idea_list sortable remove " + theme);
        $(this).append($(ui.helper).clone());
  		},
  		receive: function(event,ui){
  		  var theme = $(this).closest('div.idea_list').find('p.theme').html();
  		  //console.log("1 LIST div.idea_list receive " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
  		    ui.item.hide(1000,
  		      function(){
  		        $(this).remove();
  		        //$('div.incoming_ideas p.stats span.cnt').html( $('div#live_talking_points div.live_talking_point').size() );
  		      }
  		    ); // remove original item
  		  }
  		  var par_list = $(this).closest('div.idea_list');
  	    if( !ui.item.hasClass('live_talking_point')){
          // if there is only one copy of this idea currently
          // don't show the move/copy question if the source and dest list are the same
          if( !(par_list[0] === ui.item.data('source_list')[0]) ){
            if(par_list.hasClass('misc_list')) return;
            if( $('div.idea[idea_id="' + ui.item.attr('idea_id') + '"]').size() > 1) return; // only allow two copies total           
            var ques = $('<div class="move_or_copy_idea"><button>Move this idea to this list</button><button>Copy this idea to this list</button></div>');
            ui.item.css('background-color', '#f3973a').before(ques);
          }
        }
  		},
  		change: function(){ setTimeout(adjust_columns, 1000);},
  		delay: 50,
  		cursor: 'pointer',
  		tolerance: 'pointer',
  		connectWith: '.sortable_ideas',
  		placeholder: 'curated_list_placeholder'
  	}
  );
}
make_idea_lists_sortable( $('.sortable_ideas') );

$( "#new_theme, #misc" ).droppable({
	hoverClass: "drop_hover",
	activeClass: 'drop_active',
	tolerance: 'pointer',
	accept: '.live_talking_point',
	drop: function( event, ui ) {
		var drop_tgt = $(this);
	  if(drop_tgt.attr('id') == 'new_theme'){
	    console.log("create new_list");
	    var new_list = $('div.idea_list.new_list').clone();
	    new_list.find('div.live_talking_point, div.idea').remove();
	    new_list.removeClass('new_list');
	    new_list.hide();
	    ui.helper.remove();
	    var new_idea = ui.draggable;
	    if(new_idea.hasClass('live_talking_point')){
  		  new_idea.removeClass('live_talking_point ui-draggable');
        new_idea.addClass('idea');
      }
		  
	    new_list.find('div.ideas').append(new_idea);
	    $('div#lists div.list_column:last').append(new_list);
	    //par_list.after(new_list);
      ////console.log("call adjust_columns from make_idea_lists_sortable.receive")
	    new_list.show(1000, function(){adjust_columns();});
      // remove the orig idea from new list
      //$('div#live_talking_points div.idea[idea_id="' + new_idea.attr('idea_id') + '"]').hide(1000,function(){$(this).remove()});
	    make_idea_lists_sortable( $('.sortable_ideas') );
	    new_list.find('p.theme').html('Theme ' + idea_list_ctr++ );
	    setTimeout( function(){ fix_list_overflow( this )}.bind(new_list), 100);
	  }else if( drop_tgt.attr('id') == 'misc' ){
	    console.log("add talking point to the misc set");
	    var par_list = $('div.idea_list.misc_list');
	    var new_idea = ui.draggable;
	    if(new_idea.hasClass('live_talking_point')){
  		  new_idea.removeClass('live_talking_point ui-draggable');
        new_idea.addClass('idea');
      }
	    par_list.find('div.ideas').append(new_idea);
	    ui.helper.remove();
	    // reset the count in the title
	    var cnt = par_list.find('div.idea').size();
	    par_list.find('p.theme').html("Don't fit in (" + cnt + ")");
	    drop_tgt.html("Don't fit in (" + cnt + ")");
    }
		
	}
});

var hide_misc_list_timeout;
$( "#misc" ).live('mouseenter mouseleave', function(event) {
	var list = $('div.idea_list.misc_list');
  if (event.type == 'mouseenter') {
    if(dragging_new_idea)return;
    expand_idea_list(list);
    list.show();
  } else {
    hide_misc_list_timeout = setTimeout(
      function(){
        list.hide();
        collapse_idea_list(list);
      }
    ,500);
  }
});

$( "div.misc_list" ).live('mouseenter mouseleave', function(event) {
	var list = $('div.idea_list.misc_list');
  if(event.type == 'mouseenter'){
    clearInterval(hide_misc_list_timeout);
  }else{
    hide_misc_list_timeout = setTimeout(
      function(){
        list.hide();
        collapse_idea_list(list);
      }
    ,500);
  }
});

//clearInterval(hide_misc_list_timeout);


$('a.remove_list').live('click',
  function(){
    $(this).closest('div.idea_list').hide(1000,function(){$(this).remove()});
  }
);

var dragging_new_idea = false;
// Drag new ideas from the left and drop them into lists on the right
function make_new_ideas_draggable($ideas){
	$ideas.draggable( {
		revert: function(socketObj) {
		    if (socketObj === false) {
		        // Drop was rejected, revert the helper.
		        return true;
		    } else {
		        // Drop was accepted, don't revert.
		        return false;
		    }
		},
		revertDuration: 600,
		delay: 50,
		start: function(event,ui){
		  dragging_new_idea = true;
		  //console.log("start drag make_new_ideas_draggable")
			// refresh your sortable -- so you can drop
			$('.sortable_ideas').sortable('refresh');
			// collapse the incoming list so I can see the target lists
			//$('div.incoming_ideas').width( '' );
			ui.helper.addClass('dragged_idea');
		},
		stop: function(event,ui){
		  //console.log("New Ideas stop");
		  dragging_new_idea = false;
		},
		tolerance: 'pointer',
		connectToSortable: '.sortable_ideas',
		helper: 'clone'
	});
}

$('div.idea_list div.ideas').live('mouseenter mouseleave', function(event) {
	var list = $(this).closest('div.idea_list');
	if(list.hasClass('misc_list')) return;
  if (event.type == 'mouseenter') {
    expand_idea_list(list);
  } else {
    collapse_idea_list(list);
  }
});

$('img.info').live('mouseenter mouseleave', function(event) {
	var stats = $(this).closest('div').find('p.stats');
  if (event.type == 'mouseenter') {
    stats.show();
  } else {
    stats.hide();
  }
});

$('div.idea').live('mouseenter mouseleave', function(event) {
	var idea = $(this);
  if (event.type == 'mouseenter') {
    idea.addClass('highlighted_idea')
  } else {
    idea.removeClass('highlighted_idea')
  }
});

$('div.idea div.star').live('click', 
  function(event) {
  	var idea = $(this).closest('div.idea');
  	if(idea.hasClass('example')){
  	  idea.removeClass('example');
      //console.log("Clear idea as example for the theme/list")
  	}else{
  	  idea.addClass('example');
      //console.log("Save idea as example for the theme/list")
  	}
  }
);

make_new_ideas_draggable( $('div.live_talking_point') );

var adjust_in_process = false;
function adjust_columns(){
  if( $('div.list_column div.idea_list').size() == 0 ) return;
	if(adjust_in_process){
		setTimeout(adjust_columns, 1000);
		return;
	}
	adjust_in_process = true;
	// record the list heights			
	var list_heights = [];
	var total_height = 0;
	$('div.list_column div.idea_list').each(
		function(){
			var height = $(this).outerHeight(true);
			total_height += height;
			list_heights.push( height );
		}
	);
	//console.log("list_heights: " + list_heights.join(', ') );
	
	// determine how many columns I can fit
	var col_width = $('div.list_column').outerWidth(true);
	//var avl_width = $('div#lists').width();
	var avl_width = $('div.workspace').width() - $('div.incoming_ideas').width()
	var num_allowed_columns = Math.floor( avl_width / col_width);
	//console.log("num_allowed_columns: " + num_allowed_columns);
	
	// get the height of the lists container 
	var avl_height = $('div.lists').height();
	//console.log("avl_height: " + avl_height);
	
	// remove the lists from the columns
	var lists = $('div.list_column div.idea_list').remove();
	// remove the columns
	$('div.list_column').remove();
	
	// determine how many columns I will use - and do the columns need to scroll?
	// basically try each scenario until I find one that works
	var lists_per_col = [0];
	var fit_achieved = false;
	
	// Will it fit in one column?
	if(total_height <= avl_height){
		//console.log("fit the items into a single column");
		lists_per_col = [ lists.size() ];
		fit_achieved = true;
	}
	
	if(!fit_achieved){
		//console.log("Can I fit the lists into the avl height and # cols?");
		// add up lists till that fit within one column then the next
		while(true){
  		var lists_per_col = [0];
  		var col_ptr = 0;
  		var col_height = 0;
  		$.each( list_heights,
  			function(){
  				var list_height = this;
  				////console.log("height is " + list_height)
  				if(col_height + list_height <= avl_height){
  					++lists_per_col[col_ptr];
  					col_height += list_height;
  				}else{
  					lists_per_col.push(0);
  					++col_ptr;
  					++lists_per_col[col_ptr];
  					col_height = list_height;
  				}
  			}
  		);
  		// list_per_col is an array that show how many lists are in each column to fit within the page
  		// can the page support this many cols?
  		if( num_allowed_columns >= lists_per_col.length){
  			//console.log("I can fit the lists into " + lists_per_col.length + " columns");
  			fit_achieved = true;
  			break;
  		}
  		// can I add another column, if yes, try to make this fit again, otherwise make it scroll with code below
  	  var incoming_width = $('div.incoming_ideas').width();
  	  if(incoming_width < 300 + col_width ) break; // I don't want to squeeze incoming ideas anymore
  	  // shrink incoming width and increase # of cols
  	  $('div.incoming_ideas').width( incoming_width - col_width  );
      ++num_allowed_columns;
      // try again
  	}
	}
	
	if(!fit_achieved){
		// I cannot fit all of the lists into columns in the available view port
		// I will use the allowed # of columns and make the user will have to scroll to see them all
		// What is the optimum height for the scrolling viewport so the columns are approximately the same height?
		// play with the heights until I get the lists_per_col and then 
		//console.log("Determine the optimum length for the columns to show the lists in " + num_allowed_columns + " columns" );
		
		var target_margin = .15;
		
		while(true){
			var target_height = total_height / num_allowed_columns * ( 1 + target_margin);
			//console.log("target_height: " + target_height + " target_margin: " + target_margin + " total_height: " + total_height + " num_allowed_columns: " + num_allowed_columns);
		
			// layout the list heights under the target_height and then determine the maximum difference
			var lists_per_col = [0];
			var heights_per_col = [];
			var col_ptr = 0;
			var col_height = 0;
			$.each( list_heights,
				function(){
					var list_height = this;
					//console.log("height is " + list_height)
					if(col_height + list_height <= target_height){
						++lists_per_col[col_ptr];
						col_height += list_height;
						//heights_per_col[col_ptr] = col_height;
					}else{
						lists_per_col.push(0);
						++col_ptr;
						++lists_per_col[col_ptr];
						col_height = list_height;
						//heights_per_col[col_ptr] = col_height;
					}
				}
			);
			// make sure this target height allows all lists to fit in columns
			if( num_allowed_columns >= lists_per_col.length){
				fit_achieved = true;
				break;
			}else{
				target_margin += .1;
			}
		}
		
	}
	
	if(fit_achieved){
		//console.log("assign the list to their respective columns");
		lists = lists.toArray();
		for(var i=0, col; num_lists = lists_per_col[i];){
			//console.log("put " + num_lists + " in column " + i);
			var col = $('<div class="list_column"></div>').appendTo('div#lists');
			for(var l=0; l < num_lists; l++){
				var list = lists.shift();
				//$(list).append(' - moved into column');
				col.append(list);
			}
			++i;
		}
		make_lists_sortable();
		make_idea_lists_sortable( $('.sortable_ideas') );
	}else{
		//console.log("No satisfactory fit was achieved");
	}
	adjust_in_process = false;
}

function make_lists_sortable(){
	$('div.list_column').sortable({
		connectWith: ".list_column",
		change: function(){ setTimeout(adjust_columns, 1000);},
		delay: 50,
		cursor: 'pointer', 
		tolerance: 'pointer'
	});
}
