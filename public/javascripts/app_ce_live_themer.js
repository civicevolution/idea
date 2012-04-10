console.log("Loading app_ce_live_themer.js")
var lock_resize = false;
function live_resize(){
  //if(lock_resize)return;
  //lock_resize = true;
  if(adjust_in_process){
		setTimeout(adjust_columns, 1000);
		return;
	}
	
	// get overall avl height

	var win_height = $(window).height();
	$('body').height( win_height);
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
	  //$('div.lists').width( avl_width - incoming_width );
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
	//console.log("Collapse the list to make it fit");
	try{
	  var line_height = parseInt(list.find('p.text:first').css('line-height'));
	}catch(e){var line_height = 16;}
	var allotted_lines = 3;
	var allotted_height = allotted_lines * line_height;
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


function expand_idea_list(list){
  if(list.hasClass('misc_list') && dragging_new_idea ) return;
  
  //if this list is already expanded, just return
  if(list.hasClass('expanded'))return;
  
  // collapse any currently expanded lists
  $('div.idea_list.expanded').each(
    function(){
      if(!(this===list[0])){
        collapse_idea_list( $(this) );
      }
    }
  )
  
  //console.log("Expand_idea_list for " + list.find('p.theme').html() );
  
  list.addClass('expanded');
  list.height('auto');
  list.find('div.idea').show().height('auto');
}


no_collapse = false;
function collapse_idea_list(list){
  if(no_collapse) return;
  if(list.attr('expand'))return;
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

var dragging_new_idea = false;
// Drag new ideas from the left and drop them into lists on the right
function make_new_ideas_draggable($ideas){
	$ideas.draggable( {
		revert: function(socketObj) {
		    //console.log("new ideas draggable revert socketObj: " + socketObj)
		    if (socketObj === false) {
		        // Drop was rejected, revert the helper.
		        //console.log("rejected")
		        return true;
		    } else {
		        //console.log("accepted")
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
		cursorAt: {left: 10, top: 10},
		cursor: 'move',
		//helper: 'original',
		helper: 'clone',
		//appendTo: 'body',
		opacity: .35,
		zIndex: 2700,
		scroll: false
	});
}

$( "#new_theme, #misc" ).droppable({
	hoverClass: "drop_hover",
	activeClass: 'drop_active',
	tolerance: 'pointer',
	accept: '.live_talking_point, .idea',
	greedy: true,
	drop: function( event, ui ) {
	  //console.log("DROP #new_theme, #misc");
		var drop_tgt = $(this);
    var new_idea = ui.helper.clone();
    var source = new_idea.hasClass('live_talking_point') ? 'new' : 'theme';   
    new_idea.attr('class', 'idea');
	  new_idea.removeAttr('style');
	  
		
	  if(drop_tgt.attr('id') == 'new_theme'){
	    //console.log("create new_list");
	    var new_list = $('div.idea_list.new_list').clone();
	    new_list.find('div.live_talking_point, div.idea').remove();
	    new_list.removeClass('new_list');
	    new_list.attr('list_id',idea_list_ctr);
	    new_list.find('p.theme').html('Theme ' + idea_list_ctr++ );
	    new_list.hide();

	    new_list.find('div.ideas').append(new_idea);
	    $('div#lists div.list_column:last').append(new_list);

	    new_list.show(1000, function(){adjust_columns();});

	    make_idea_lists_sortable( $('.sortable_ideas') );

      if(source == 'new'){
	      remove_talking_point( new_idea );
	    }else{
	      var id = ui.helper.attr('idea_id');
	      $('div.idea[idea_id="' + id + '"]').not(new_idea).hide( 1000, function(){ $(this).remove();});
	      ui.helper.remove();
	    }
	    
	    setTimeout( function(){ fix_list_overflow( this )}.bind(new_list), 100);
	  }else if( drop_tgt.attr('id') == 'misc' ){
	    //console.log("add talking point to the misc set");
	    var par_list = $('div.idea_list.misc_list');
    
	    par_list.find('div.ideas').append(new_idea);
	    
	    // remove duplicate ideas
	    var idea_ids = {};
    	par_list.find('div.idea').each(
    	  function(){
    	    var idea = $(this);
    	    var id = idea.attr('idea_id');
    	    if(idea_ids[ id ]){
    	      idea.remove();
    	    }else{
    	      idea_ids[ id ] = id;
    	    }
    	  }
    	);
	    
	    // reset the count in the title
	    var cnt = par_list.find('div.idea').size();
	    par_list.find('p.theme').html("Don't fit in (" + cnt + ")");
	    drop_tgt.html("Add to don't fit(" + cnt + ")");
	    
      if(source == 'new'){
	      remove_talking_point( new_idea );
	    }else{
	      var id = ui.helper.attr('idea_id');
	      $('div.idea[idea_id="' + id + '"]').not(new_idea).hide( 1000, function(){ $(this).remove();});
	      ui.helper.remove();
	    }

    }
	}
});

// Sort the ideas within a list
function make_idea_lists_sortable($idea_lists){
  //console.log("make_idea_lists_sortable for " + $idea_lists.size() )
  $idea_lists.sortable(
  	{
  		start: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
  		  console.log("sortable start " + theme); 
  		  if( !ui.item.hasClass('live_talking_point') ){
  		    ui.item.attr('source_list_id',idea_list.attr('list_id'));
    		  ui.item.attr('prev_idea_id',ui.item.prev('.idea').attr('idea_id'));
  		  }
  		  if(idea_list.attr('list_id') == 'misc'){
  		    //collapse_idea_list(idea_list);
  		    //idea_list.hide();
  		    //ui.item.show();
  		  }
  		},
  		over: function(event,ui){
  		  var list = $(this).closest('div.idea_list');
  		  console.log("expand for sortable over " + list.find('p.theme').html())
  		  expand_idea_list(list);
		  },
  		stop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        console.log("sortable stop " + theme);
  			setTimeout(function(){clean_up_theme(this);}.bind(idea_list),100);
  		},
  		remove: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        console.log("sortable remove " + theme)
        //$(this).append($(ui.helper).clone());
  		},
  		receive: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        console.log("sortable receive " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
    		  new_idea = $(this).find('div.live_talking_point')
    		  new_idea.attr('class', 'idea');
    		  new_idea.removeAttr('style');
    		  remove_talking_point( new_idea );
  		  }else{
  		    
          // don't show the move/copy question if the source and dest list are the same
          try{
            var source_list_id = ui.item.attr('source_list_id');
            var source_list = $('div.idea_list[list_id="' + source_list_id + '"]');
            
            if( source_list_id != 'misc' && source_list && !(idea_list[0] === source_list[0]) ){
              if( $('div.idea[idea_id="' + ui.item.attr('idea_id') + '"]').size() < 2){ // only allow two copies total           
                var ques = $('<div class="move_or_copy_idea"><button>Move this idea to this list</button><button>Copy this idea to this list</button></div>');
                ui.item.css('background-color', '#f3973a').before(ques);
              }
            }
          }catch(e){
            debugger
          }                                                                                                                                                   		    
  		  }
  		  setTimeout(function(){clean_up_theme(this);}.bind(idea_list),100);
  		},
  		change: function(){ setTimeout(adjust_columns, 1000);},
  		//appendTo: 'div.lists',
  		helper: 'clone',
  		//containment: 'div.lists',
  		delay: 50,
  		cursorAt: {left: 10, top: 10},
  		cursor: 'move',
  		tolerance: 'pointer',
  		connectWith: '.sortable_ideas',
  		placeholder: 'curated_list_placeholder'
  	}
  );
}
make_idea_lists_sortable( $('.sortable_ideas') );

function clean_up_theme(list){
  // remove duplicate ideas
  console.log("clean_up_theme theme: " + list.find('p.theme').html() );
	var idea_ids = {};
	if(list.attr('list_id') != 'misc'){
  	// no ideas in lists that is already in the misc list
    $('div.misc_list div.idea').each( function(){var id = $(this).attr('idea_id'); idea_ids[id] = id;});
  }
	list.find('div.idea').each(
	  function(){
	    var idea = $(this);
	    var id = idea.attr('idea_id');
	    if(idea_ids[ id ]){
	      idea.remove();
	    }else{
	      idea_ids[ id ] = id;
	    }
	  }
	);
	if(list.attr('list_id') == 'misc'){
  	// reset the count in the title
    var cnt = list.find('div.idea').size();
    list.find('p.theme').html("Don't fit in (" + cnt + ")");
    $('div.drop_ribbon div#misc').html("Add to don't fit(" + cnt + ")");
  }else{
    if( list.find('div.idea').size() == 0 ){
  	  list.find('div.ideas').html(
  	    '<a href="#" class="remove_list">Remove empty list</a>');
  	}else{
  	  list.find('a.remove_list').remove();
  	}
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

      var source_list_id = idea.attr('source_list_id');
      var source_list = $('div.idea_list[list_id="' + source_list_id + '"]');
      
      var prev_idea_id = idea.attr('prev_idea_id');
      var prev_idea = $('div.idea[idea_id="' + prev_idea_id + '"]');
      
      if( prev_idea.size() > 0 ){
        prev_idea.after(idea.clone());
      }else{
        source_list.find('div.ideas').prepend(idea.clone());
        source_list.find('a.remove_list').remove();
      }
    }
    var list = div.closest('div.idea_list');
    div.remove();
    setTimeout(function(){clean_up_theme(this);}.bind(source_list),100);
    setTimeout(function(){clean_up_theme(this);}.bind(list),100);
  }
);


function remove_talking_point( tp ){
  // remove this talking point from incoming, but make sure it appears somewhere else
  var id = tp.attr('idea_id');
  $('div#live_talking_points div.live_talking_point[idea_id=' + id + ']').hide(800, function(){$(this).remove();});
}

var hide_misc_list_timeout;
$( "#misc" ).live('mouseenter mouseleave', function(event) {
	var list = $('div.idea_list.misc_list');
  if (event.type == 'mouseenter') {
    if(dragging_new_idea)return;
    expand_idea_list(list);
    list.show();
    $('div#lists').scrollTop(0);
  } else {
    hide_misc_list_timeout = setTimeout(
      function(){
        list.hide();
        collapse_idea_list(list);
      }
    ,800);
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
    ,800);
  }
});

//clearInterval(hide_misc_list_timeout);


$('a.remove_list').live('click',
  function(){
    console.log("remove_list")
    $(this).closest('div.idea_list').hide(1000,function(){$(this).remove()});
  }
);

var collapseTimer;
$('div.idea_list div.ideas').live('mouseenter mouseleave', function(event) {
	var list = $(this).closest('div.idea_list');
	if(list.hasClass('misc_list')) return;
  if (event.type == 'mouseenter') {
    //console.log("expand for mouseenter list " + list.find('p.theme').html() );
    expand_idea_list(list);
  } else {
    collapseTimer = setTimeout( function(){ collapse_idea_list($(this));}.bind(list), 100);
    //collapse_idea_list(list);
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

var expanded_mode = false;
$('#toggle_lists').live('click', 
  function(){
    console.log("toggle_lists expanded_mode: " + expanded_mode);
    if(expanded_mode){
      expanded_mode = false;
      $(this).find('p').html('E');
      $('div.list_column div.idea_list').each(
      	function(){
      		var list = $(this);
      		list.removeAttr('expand');
      		collapse_idea_list( list );		
      	}
      )
    }else{
      expanded_mode = true;
      $(this).find('p').html('C');
      $('div.list_column div.idea_list').each(
      	function(){
      		var list = $(this);
      		list.attr('expand',true)
      		expand_idea_list( list );		
      	}
      )
    }
  }
);



make_new_ideas_draggable( $('div.live_talking_point') );

var adjust_in_process = false;
function adjust_columns(){
  var force_single_column = false;
  if( $('div.list_column div.idea_list').size() == 0 ) return;
  if(dragging_new_idea) return;
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
	
	if(force_single_column) num_allowed_columns = 1;
	
	
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
	if(total_height <= avl_height && !force_single_column){
		//console.log("fit the items into a single column");
		lists_per_col = [ lists.size() ];
		fit_achieved = true;
	}
	
	if(!fit_achieved && !force_single_column){
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
  		//console.log("***** Try to add another column to the lists");
  		// can I add another column, if yes, try to make this fit again, otherwise make it scroll with code below
  	  var incoming_width = $('div.incoming_ideas').width();
  	  // but check if there is any dead space I can also use
  	  //console.log("incoming_width: " + incoming_width);
  	  
  	  var free_space = $('div.workspace').width() - incoming_width - col_width * num_allowed_columns - 20;
  	  //console.log("$('div.workspace').width(): " + $('div.workspace').width());
  	  //console.log("free_space: " + free_space);
  	  
  	  //console.log("col_width: " + col_width);
  	  
  	  if(incoming_width + free_space < 300 + col_width ) break; // I don't want to squeeze incoming ideas anymore
  	  // shrink incoming width and increase # of cols
  	  //console.log("set incoming width to " + (incoming_width - ( col_width - free_space ) )  );
  	  var new_incoming_width = incoming_width - ( col_width - free_space );
  	  $('div.incoming_ideas').width( new_incoming_width - 30 );
  	  
  	  $('div.lists').width( $('div.workspace').width() - new_incoming_width );
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


$('div.auto-scroll')
	.mousemove(function(e) {checkMouse(e.pageX, e.pageY, this);})
	.bind('mouseleave', function() {stopMoving();})
	.bind('mouseenter', function() { clearTimeout(collapseTimer);});

var auto_scroll_params = { direction: 0, speed: 2, timer: 0, interval: 50, intervalTimer: null };
function checkMouse(x, y, ctnr) {
	var ctnr = $(ctnr);
	y = y - ctnr.offset().top;
	// convert y to speed
	if(ctnr.attr('id').match(/top/)){
		auto_scroll_params.direction = -1;
		speed = 21 - y;
	}else{
		auto_scroll_params.direction = 1;
		speed = y + 1;
	}
	speed = Math.round( speed/2 );
	speed = speed < 2 ? 2 : speed;
	auto_scroll_params.speed = speed;
	if(!auto_scroll_params.intervalTimer){
	  auto_scroll_params.intervalTimer = setInterval(move, auto_scroll_params.interval);
	}
	//move();
	//console.log("checkMouse auto_scroll_params.direction: " + auto_scroll_params.direction + ", 	auto_scroll_params.speed: " + 	auto_scroll_params.speed);
}

function stopMoving(){
	clearInterval(auto_scroll_params.intervalTimer );
	auto_scroll_params.intervalTimer = null;
	//console.log("stopMoving");
	auto_scroll_params.speed = 2;
	auto_scroll_params.direction = 0;
}

function move() {
  if(auto_scroll_params.direction == 0){
    stopMoving();
    return;
  }
	var scrollIncrement = auto_scroll_params.direction * auto_scroll_params.speed;
  //console.log("move with speed: " + auto_scroll_params.speed + " scrollIncrement: " + scrollIncrement);
  
	//$(window).scrollTop( $(window).scrollTop() + scrollIncrement );
	
	$('div#lists').scrollTop( $('div#lists').scrollTop() + scrollIncrement );
	
	
	//auto_scroll_params.timer = setTimeout(function() {move();}, auto_scroll_params.interval);
}