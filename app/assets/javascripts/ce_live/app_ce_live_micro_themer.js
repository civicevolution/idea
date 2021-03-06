//console.log("Loading app_ce_live_themer.js")
var lock_resize = false;
function live_resize(){
	return false;
  //if(lock_resize)return;
  //lock_resize = true;
  if(adjust_in_process){
		setTimeout(live_resize, 1000);
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
	  var inner_padding = 30;
	  ltp.find('div.inner').height( ltp.height() - 4 - inner_padding);
	  
  	var lists = $('div.lists');
  	lists.height(ws.height() + 8);
  	//lists.height(ws.height() - 214);
  	var ribbon = lists.find('div.drop_ribbon').outerHeight(true);
  	var lists_ws = $('div#lists');
	  lists_ws.height(lists.height() - ribbon - 20);
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
	  //console.log("call adjust_columns in 1 sec because the page has been resized");
	  setTimeout(adjust_columns, 400);
	}
}

setTimeout(live_resize,100);
setTimeout(
  function(){
    expanded_mode = true;
    $('#toggle_lists').click();
  },
  1000
);


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


function expand_idea_list(list){}
function expand_idea_listX(list){
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
function collapse_idea_list(list){}
function collapse_idea_listX(list){
  if(no_collapse) return;
  if(list.attr('expand'))return;
  //console.log("collapse_idea_list for " + list.find('p.theme').html() );
  
  $('div.idea_list_placeholder').remove();
  list.removeClass('expanded');  
  fix_list_overflow(list);
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
		return false;
	}
)

var idea_list_ctr = $('div.list_column div.idea_list').size() + 1;

var dragging_new_idea = false;
var dragging_idea = false;
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
		//distance: 6,
		//helper: 'original',
		helper: 'clone',
		//appendTo: 'body',
		opacity: .35,
		zIndex: 2700,
		scroll: false
	});
}

if(!disable_editing){
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
  	    new_list.attr('list_id','new_list_' + idea_list_ctr);
  	    new_list.find('p.theme').html('Theme ' + idea_list_ctr++ );
  	    new_list.hide();

  	    new_list.find('div.ideas').append(new_idea);
  	    $('div#lists div.list_column:last').append(new_list);

  	    new_list.show(1000, function(){
  	      //console.log("call adjust_columns in 1 sec because a new list has been added");
  	      setTimeout(adjust_columns, 400);
  	    });

  	    make_idea_lists_sortable( $('.sortable_ideas') );

        if(source == 'new'){
  	      remove_talking_point( new_idea );
  	    }else{
  	      var id = ui.helper.attr('idea_id');
  	      $('div.idea[idea_id="' + id + '"]').not(new_idea).hide( 1000, function(){ $(this).remove();});
  	      ui.helper.remove();
  	    }
	    
  	    // get the list ids in order 
  	    var list_ids = [];
  	    $('div.idea_list').each(
  	      function(){
  	        list_ids.push($(this).attr('list_id') );
  	      }
  	    );
  	    //console.log("add new_list, ids: " + list_ids);
	    
  	    post_theme_changes({act: 'new_list', text: new_list.find('p.theme').html(), list_id: new_list.attr('list_id'),
  	      output_tag: page_data.output_tag, list_ids: list_ids, ltp_ids: new_idea.attr('idea_id') })
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
  	    drop_tgt.html("Don't fit(" + cnt + ")");
	    
  	    // get the list ids in order 
  	    var ltp_ids = [];
  	    par_list.find('div.idea').each(
  	      function(){
  	        ltp_ids.push($(this).attr('idea_id') );
  	      }
  	    );
  	    post_theme_changes({act: 'add_misc_live_talking_point', ltp_ids: ltp_ids, list_id: 0 });
		  
	    
        if(source == 'new'){
  	      remove_talking_point( new_idea );
  	    }else{
  	      var id = ui.helper.attr('idea_id');
  	      ui.helper.closest('.idea_list').find('div.idea[idea_id="' + id + '"]').not(new_idea).hide( 1000, function(){ $(this).remove();});
  	      ui.helper.remove();
  	    }

      }
  	}
  });
}

// Sort the ideas within a list
function make_idea_lists_sortable($idea_lists){
  //console.log("make_idea_lists_sortable for " + $idea_lists.size() )
  $idea_lists.sortable(
  	{
  		start: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  
  		  var ltp_ids = [];
  	    idea_list.find('div.idea').each(
  	      function(){
  	        ltp_ids.push($(this).attr('idea_id') );
  	      }
  	    );
  		  idea_list.attr('idea_ids',ltp_ids.join(',') );
  		  console.log("start sortable with idea_ids: " + ltp_ids.join(',') );
  		  var theme = idea_list.find('p.theme').html();
  		  //console.log("sortable start " + theme); 
  		  if( !ui.item.hasClass('live_talking_point') ){
  		    ui.item.attr('source_list_id',idea_list.attr('list_id'));
    		  ui.item.attr('prev_idea_id',ui.item.prev('.idea').attr('idea_id'));
    		  dragging_idea = true;
  		  }else{
  		    dragging_new_idea = true;
  		  }
  		  if(idea_list.hasClass('misc_list')){
  		    //console.log("hide the misc list immediately");
  		    idea_list.hide();
  		    collapse_idea_listX(idea_list);
  		    $(this).show();
  		    $('div.lists').append(ui.helper)
  		  }
  		  expand_idea_listX(idea_list);
  		},
  		over: function(event,ui){
  		  var list = $(this).closest('div.idea_list');
  		  //console.log("expand for sortable over " + list.find('p.theme').html())
  		  expand_idea_list(list);
		  },
  		stop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        //console.log("sortable stop " + theme);
  			setTimeout(function(){clean_up_theme(this);}.bind(idea_list),100);
  			dragging_idea = false;
  			//console.log("call adjust_columns in 1 sec because the sortable ideas has stopped: CHECK IF ACTUAL CHANGE");
  		  setTimeout(adjust_columns, 400);
  		  
  	    setTimeout( function(){ post_idea_ids('update_list_idea_ids', this) }.bind(idea_list), 400);
  	    
  		},
  		remove: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        //console.log("sortable remove " + theme);
        
  	    setTimeout( function(){ post_idea_ids('remove_live_talking_point', this) }.bind(idea_list), 400);
  	    
  		},
  		receive: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
        //console.log("sortable receive " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
    		  new_idea = $(this).find('div.live_talking_point')
    		  new_idea.attr('class', 'idea');
    		  new_idea.removeAttr('style');
    		  remove_talking_point( new_idea );
  		  }

  	    setTimeout( function(){ post_idea_ids('receive_live_talking_point', this) }.bind(idea_list), 400);
        
  		  setTimeout(function(){clean_up_theme(this);}.bind(idea_list),100);
  		},
  		//appendTo: 'div.lists',
  		helper: 'clone',
  		//containment: 'div.lists',
  		delay: 50,
  		//cursorAt: {left: 10, top: 10},
  		cursor: 'move',
  		//distance: 6,
  		tolerance: 'pointer',
  		//tolerance: 'intersect',
  		connectWith: '.sortable_ideas',
  		placeholder: 'curated_list_placeholder'
  	}
  );
}
if(!disable_editing){
  make_idea_lists_sortable( $('.sortable_ideas') );
}

function make_lists_sortable(){
	$('div.list_column').sortable({
		connectWith: ".list_column",
		stop: function(){ 
		  // get the list ids in order 
	    var list_ids = [];
	    $('div.idea_list').each(
	      function(){
	        list_ids.push($(this).attr('list_id') );
	      }
	    );
	    //console.log("change lists order, ids: " + list_ids);
	    
	    post_theme_changes({act: 'reorder_lists', list_ids: list_ids });
	    
		  //console.log("call adjust_columns in 1 sec because the order of the lists has been changed");
		  setTimeout(adjust_columns, 400);
		},
		delay: 50,
		cursor: 'move', 
		tolerance: 'pointer'
	});
}

function post_idea_ids(act, idea_list){
  // was there a change in the lists ideas/order?
  var ltp_ids = [];
  idea_list.find('div.idea').each(
    function(){
      ltp_ids.push($(this).attr('idea_id') );
    }
  );
  var old_ltp_ids = idea_list.attr('idea_ids' );
  if( ltp_ids.join(',') != old_ltp_ids){
    idea_list.attr('idea_ids', ltp_ids.join(',') );
    post_theme_changes({act: act, ltp_ids: ltp_ids, list_id: idea_list.attr('list_id') });
  }
}

function clean_up_theme(list){
  // remove duplicate ideas
  //console.log("clean_up_theme theme: " + list.find('p.theme').html() );
	var idea_ids = {};
	list.find('div.idea').each(
	  function(){
	    var idea = $(this);
	    var id = idea.attr('idea_id');
	    if(idea_ids[ id ]){
	      //console.log("remove the id " + idea.find('p.text').html() );
	      idea.remove();
	    }else{
	      idea_ids[ id ] = id;
	    }
	  }
	);
	if(list.attr('list_id') == 'misc'){
	  var old_cnt = list.find('p.theme').html().match(/\d+/)
	                                   
  	// reset the count in the title
    var new_cnt = list.find('div.idea').size();
    list.find('p.theme').html("Don't fit in (" + new_cnt + ")");
    $('div.drop_ribbon div#misc').html("Don't fit(" + new_cnt + ")");
    
    if(old_cnt && Number(old_cnt[0]) != new_cnt){
      // get the list ids in order 
      var ltp_ids = [];
      list.find('div.idea').each(
        function(){
          ltp_ids.push($(this).attr('idea_id') );
        }
      );
      post_theme_changes({act: 'add_misc_live_talking_point', ltp_ids: ltp_ids });
	  }
    
    
    
  }else{
    if( list.find('div.idea').size() == 0 ){
      list.addClass('empty_list');
  	}else{
  	  list.removeClass('empty_list');
  	}
  }
}

function remove_talking_point( tp ){
  // remove this talking point from incoming, but make sure it appears somewhere else
  var id = tp.attr('idea_id');
  $('div#live_talking_points div.live_talking_point[idea_id=' + id + ']').hide(800, function(){$(this).remove();});
}

var hide_misc_list_timeout;
$( "#misc" ).live('mouseenter mouseleave', function(event) {
	var list = $('div.idea_list.misc_list');
  if (event.type == 'mouseenter') {
    //console.log("#misc mouseenter ");
    if(dragging_new_idea)return;
    expand_idea_list(list);
    list.show();
    $('div#lists').scrollTop(0);
  } else {
    //console.log("#misc mouseleave ");
    hide_misc_list_timeout = setTimeout(
      function(){
        this.hide();
        collapse_idea_listX(this);
      }.bind(list)
    ,200);
  }
});

$( "div.misc_list" ).live('mouseenter mouseleave', function(event) {
	var list = $('div.idea_list.misc_list');
  if(event.type == 'mouseenter'){
    clearInterval(hide_misc_list_timeout);
  }else{
    hide_misc_list_timeout = setTimeout(
      function(){
        this.hide();
        collapse_idea_listX(this);
      }.bind(list)
    ,200);
  }
});

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
  //console.log("('img.info').live('mouseenter mouseleave'");
	var stats = $(this).closest('div').find('p.stats');
	var idea = stats.closest('div.idea');
  if (event.type == 'mouseenter') {
    stats.show();
    idea.attr('old_style', idea.attr('style'))
    idea.removeAttr('style');
  } else {
    stats.hide();
    idea.attr('style', idea.attr('old_style'));
    idea.removeAttr('old_style');
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
    if(editing_disabled())return false;
  	var idea = $(this).closest('div.idea');
  	if(idea.hasClass('example')){
  	  idea.removeClass('example');
      //console.log("Clear idea as example for the theme/list")
  	}else{
  	  idea.addClass('example');
      //console.log("Save idea as example for the theme/list")
  	}
  	
  	var list = idea.closest('div.idea_list');
  	// get the example ids for this list
    var example_ids = [];
    list.find('div.idea.example').each(
      function(){
        example_ids.push($(this).attr('idea_id') );
      }
    );
  	post_theme_changes({act: 'update_theme_examples', example_ids: example_ids, list_id: list.attr('list_id') })
  	
  }
);

var expanded_mode = false;
$('#toggle_lists').live('click', 
  function(){
    //console.log("toggle_lists expanded_mode: " + expanded_mode);
    if(expanded_mode){
      expanded_mode = false;
      $(this).find('p').html('Expand all');
      $('div.list_column div.idea_list').each(
      	function(){
      		var list = $(this);
      		list.removeAttr('expand');
      		collapse_idea_listX( list );		
      	}
      )
    }else{
      expanded_mode = true;
      $(this).find('p').html('Collapse all');
      $('div.list_column div.idea_list').each(
      	function(){
      		var list = $(this);
      		list.attr('expand',true)
      		expand_idea_listX( list );		
      	}
      )
    }
  }
);


$('div.control_bar div').die('click').live('click',
  function(){
    var div = $(this);
    var list = div.closest('div.idea_list');
    if(div.hasClass('expand')){
      list.attr('expand',true);
      expand_idea_listX( list );	
    }else{
      list.removeAttr('expand');
      collapse_idea_listX( list );	
    }
  }
);



if(!disable_editing){
  make_new_ideas_draggable( $('div.live_talking_point') );
}

var adjust_in_process = false;
function adjust_columns(){
  var force_single_column = false;
  if( $('div.list_column div.idea_list').size() == 0 ){
    adjust_auto_scroll_width();
    return;
  }
	if(adjust_in_process){
	  //console.log("call adjust_columns in 1 sec because the adjust columns is in process");
		setTimeout(adjust_columns, 800);
		return;
	}
	if($('div.idea_list.expanded').size() > 0 ){
	  //console.log("call adjust_columns in 1 sec because one or more lists are expanded");
		setTimeout(adjust_columns, 800);
		return;
	}
	if(dragging_new_idea || dragging_idea) return; // if these impact the lists, this will get called again
	adjust_in_process = true;
	//console.log("adjust_columns now");
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
		if(!disable_editing){
  		make_lists_sortable();
  		make_idea_lists_sortable( $('.sortable_ideas') );
  	}
	}else{
		//console.log("No satisfactory fit was achieved");
	}
	adjust_auto_scroll_width();
	adjust_in_process = false;
}
function adjust_auto_scroll_width(){
	$('div.incoming_ideas div#auto_bottom.auto-scroll.incoming_scroll').width( $('div.incoming_ideas').width());
	var lists = $('div.lists');
	lists.find('div#auto_bottom.auto-scroll.lists_scroll').width( lists.width() ).css('left', lists.offset().left);
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
	  auto_scroll_params.intervalTimer = setInterval( function(){move(this);}.bind(ctnr), auto_scroll_params.interval);
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

function move(ctnr) {
  if(auto_scroll_params.direction == 0){
    stopMoving();
    return;
  }
	var scrollIncrement = auto_scroll_params.direction * auto_scroll_params.speed;
  //console.log("move with speed: " + auto_scroll_params.speed + " scrollIncrement: " + scrollIncrement);
  
	if(ctnr.hasClass('lists_scroll')){
	  ctnr = $('div#lists');
	}else{
	  ctnr = $('div#live_talking_points div.inner');
	}
	ctnr.scrollTop( ctnr.scrollTop() + scrollIncrement );
}

$('#themer.theme div.idea_list div.edit').live('click',
  function(){
    if(editing_disabled())return false;
    //console.log("edit the theme");
		$('.sortable_ideas').sortable('disable');
		$('div.list_column').sortable('disable');
		var form = $(template_functions['live_micro_theme_form']({}));
		var list = $(this).closest('.idea_list');
		list.attr('expand',true);
		expand_idea_listX(list);
		var header = list.find('div.header div.theme');
		if( header.find('p.theme').html().match(/^\s*Theme \d*\s*$/)){
		  form.find('textarea').val('');
		}else{
		  form.find('textarea').val( header.find('p.theme').html() );
		}
		header.hide().after(form);
		form.find('textarea').focus()
		return false;
	}
);
$('#themer.theme div.idea_list div.header :submit').die('click').live('click',
	function(){
		$('.sortable_ideas').sortable('enable');
		$('div.list_column').sortable('enable');
		var list = $(this).closest('.idea_list');
		var header = list.find('div.header div.theme');
		var edit_div = list.find('div.header div.edit_theme');
		var new_theme = edit_div.find('textarea').val();
		if(new_theme.trim() == ''){
		  new_theme = header.find('p.theme').html();
		}
		header.find('p.theme').html(new_theme);
		
		post_theme_changes({act: 'update_theme_text', text: new_theme, list_id: list.attr('list_id') })
		
		header.show();
		edit_div.remove();
		list.removeAttr('expand');
		return false;
	}
);
$('#themer.theme div.idea_list div.header a.cancel').die('click').live('click',
	function(){
		$('.sortable_ideas').sortable('enable');
		$('div.list_column').sortable('enable');
		var list = $(this).closest('.idea_list');
		var header = list.find('div.header div.theme');
		var edit_div = list.find('div.header div.edit_theme');
		header.show();
		edit_div.remove();
		list.removeAttr('expand');
		return false;
	}
);

$( "div.idea_list" ).live('mouseenter mouseleave', function(event) {
  if (event.type == 'mouseenter') {
    $(this).addClass('has_focus')
  } else {
    $(this).removeClass('has_focus')
  }
});

$( "div.live_talking_point" ).live('mouseenter mouseleave', function(event) {
  if (event.type == 'mouseenter') {
    $(this).addClass('highlighted_idea')
  } else {
    $(this).removeClass('highlighted_idea')
  }
});


$('img.tp_delete').die('click').live('click',
  function(){
    if(editing_disabled())return false;
    console.log("delete this item from the group");
    var list = $(this).closest('div.idea_list');
    var idea = $(this).closest('div.idea');
    if(idea.size()>0){
      post_theme_changes({act: 'delete_theme_child', list_id: list.attr('list_id'), idea_id: idea.attr('idea_id') });
    }else{
      post_theme_changes({act: 'delete_theme', list_id: list.attr('list_id') });
    }
  }
);

post_theme_changes.update_fn = function(){
  $('div.table').each(
    function(){
      var stat = $(this);
      var table_id = stat.attr('table_id');
      stat.find('span.unthemed_tp_count').html( ':' + $('div.live_talking_point[table_id="' + table_id + '"]').size() );
      stat.find('span.themed_tp_count').html( '-' + $('div.list_column div.idea[table_id="' + table_id + '"]').size() );
      stat.find('span.example_tp_count').html( '-' + $('div.list_column div.idea.example[table_id="' + table_id + '"]').size() );
    }
  );
}
post_theme_changes.update_fn();

setTimeout(expire_old_status,10000);
function expire_old_status(){
  //console.log("expire_old_status");
  $('div.table').each(
    function(){
      var stat = $(this);
      var last_update_ctr = stat.attr('last_update_ctr');
      if(last_update_ctr++ < 3){
        stat.attr('last_update_ctr', last_update_ctr);
      }else{
        stat.addClass('warn');
      }
    }
  );
  setTimeout(expire_old_status,10000);
}

function update_status_report(message){
  if(message.role == 'scribe' &&
    message.page_type.session_id == page_data.source_session_id &&
    message.page_type.type == 'enter talking points'
  ){
    try{
      var table_id = message.name.match(/\d+/)[0];
      var stat = $('div.table[table_id="' + table_id + '"]');
      stat.attr('jug_id', message.jug_id);
      $('div.chat[table_id="' + table_id + '"] input#jug_id').val( message.jug_id );
      stat.removeClass('warn');
      stat.attr('last_update_ctr',0);
    }catch(e){}
  }
}

$( "div.table" ).live('mouseenter mouseleave', function(event) {
  var div = $(this);
  if (event.type == 'mouseenter') {
    var offset = div.offset();
    div.find('div.table_menu').css({display: 'block', top: offset.top + div.outerHeight(), left: offset.left });
  } else {
    
    div.find('div.table_menu').css({display: 'none'})
  }
});

$('div.show_chat').live('click',
  function(){
    var table_div = $(this).closest('div.table');
    if(table_div.hasClass('warn')) return;
    table_div.removeClass('new_message');
    table_div.find('div.table_menu').hide();
    var table_id = table_div.attr('table_id');
    var chat = $('div.chat[table_id="' + table_id +'"]');
    if(chat.size()==0){
      chat = add_chat_form(table_id, table_div.attr('jug_id') );
    }
    $('div.chat').not('div#coord_chat').hide();
    var offset = table_div.offset();
    chat.css({display: 'block', top: offset.top + table_div.outerHeight(), left: offset.left });
    chat.find('input[type="text"]').focus();
  }
);
$('div.chat p.hdr a').live('click',
  function(){
    $(this).closest('div.chat').hide();
    return false;
  }
);
function add_chat_form(table_id, jug_id){
  console.log("add_chat_form table_id: " + table_id + ', jug_id: ' + jug_id);
  var chat = $('div.chat.orig').clone();
  chat.removeClass('orig').attr('table_id',table_id);
  // set the recip_jug_id when I open the table chat
  chat.find('input#jug_id').val( jug_id );
  chat.find('span.table_id').html(table_id);
  $('body').append(chat);
  return chat;
}

function update_chat(data){
  if(data.id == themer_parent_jug_id){
     update_coordinator_chat(data);
     return;
  }
  var table_div = $('div.table[jug_id="' + data.id + '"]');
  var table_id = table_div.attr('table_id');
  var chat = $('div.chat input#jug_id[value="' + data.id + '"]').closest('div.chat');
  if(chat.size() == 0){
    // create chat if it doesn't exist
    var chat = add_chat_form(table_id, data.id);
  }
  var chat_log = chat.find('div.chat_log');
  // add message to chat
  if(chat_log.find('p:last').attr('node_id') == data.node_id){
    chat_log.append('<p node_id="' + data.node_id + '">' + data.msg + '</p>').scrollTop(99999999);
  }else{
    chat_log.append('<p node_id="' + data.node_id + '">' + data.name + ': ' + data.msg + '</p>').scrollTop(99999999);
  }
  // add message indicator
  table_div.addClass('new_message');
  // show message for 5 secs, unless this chat form is already visible
  if( !chat.is(':visible') ){
    var msg_alert = $('<div class="chat_alert">Msg from T' + table_id + ': ' + data.msg + '</div>');
    $('body').append(msg_alert);
    var offset = table_div.offset();
    msg_alert.css({top: offset.top + table_div.outerHeight(), left: offset.left, 'z-index': 1000 });
    msg_alert.fadeTo(3000,1,function(){$(this).fadeTo(2000,0,function(){$(this).remove();})});
  }
}
$('a.canned_messages').live('click',
  function(){
    console.log("canned_messages");
    var chat = $(this).closest('div.chat');
    var canned_messages = chat.find('div.canned_messages');
    canned_messages.toggle();
    return false;
  }
);
$('div.canned_messages a').live('click',
  function(){
    console.log("Use this canned_message");
    $(this).closest('div.chat').find('input#msg').val( $(this).html() );
    $(this).closest('div.chat').find('div.canned_messages').hide();
    return false;
  }
);


$('div.show_tp').live('click',
  function(){
    console.log("Show all the tp for this table");
  	$.getScript('/live/' + page_data.session_id + '/group_tp/' + $(this).closest('div.table').attr('table_id') )
    $(this).closest('div.table_menu').hide();
  }
);


function update_coordinator_chat(data){
  var chat = $('div#coord_chat');
  var link = $('a.coord_chat');
  var offset = link.offset();
  chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left })
  
  var chat_log = chat.find('div.chat_log');
  if(chat_log.find('p:last').attr('node_id') == data.node_id){
    chat_log.append('<p node_id="' + data.node_id + '">' + data.msg + '</p>').scrollTop(99999999);
  }else{
    chat_log.append('<p node_id="' + data.node_id + '">' + data.name + ': ' + data.msg + '</p>').scrollTop(99999999);
  }
}
$('div.chat p.hdr a').live('click',
  function(){
    $(this).closest('div.chat').hide();
    return false;
  }
);

$(function(){
  $('div.join_com').prepend(' /');
  $('div.join_com').prepend( $('<a href="#" class="coord_chat">Chat with coordinator</a>') );
  $('div.join_com').prepend(' / ');
  $('div.join_com').prepend( $('<a href="#" class="fix_page">Fix page</a>') );
});
$('a.fix_page').live('click',function(){live_resize(); return false;});
$('a.coord_chat').live('click',
  function(){
    var chat = $('div#coord_chat');
    var link = $(this);
    var offset = link.offset();
    chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left });
    chat.find('input[type="text"]').focus();
    return false;
  }
);