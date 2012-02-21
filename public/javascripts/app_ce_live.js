console.log("Loading app_ce_live.js")
function live_resize(){
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
  	var h3_height = lists.find('h3').outerHeight(true);
  	var lists_ws = $('div#lists');
	  lists_ws.height(lists.height() - h3_height - 10);
	  //var inner_padding = 20;
	  //ltp.find('div.inner').height( ltp.height() - 4 - inner_padding);
	  
	  lists.width( ws.width() - lists.position().left - 10 )
	  //console.log("call adjust_lists from live_resize")
	  adjust_lists();
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
		var num_ideas = list.find('div.idea').size();
		var avl_height = list.height() - list.find('div.header').outerHeight(); 
		var idea_margin = 12;
		var height_per_idea = (avl_height - num_ideas * idea_margin)/num_ideas;
		height_per_idea -= height_per_idea % line_height;
		if(height_per_idea < line_height)height_per_idea = line_height;
		//console.log("set each idea height to " + height_per_idea)
		//list.attr('list_height',list.height());
		list.attr('height_per_idea',height_per_idea);
		list.find('div.idea').height(height_per_idea);
	}
}

function expand_idea_list(list){
  //console.log("expand_idea_list for " + list.find('p.theme').html() )
  if( $('div.idea_list.expanded').size() > 0)return;
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
  list.find('div.idea').height('auto');
  list.height('auto');
}
no_collapse = false;
function collapse_idea_list(list){
  if(no_collapse) return;
  //console.log("collapse_idea_list for " + list.find('p.theme').html() )
  $('div.idea_list_placeholder').remove();
  list.removeClass('expanded');  
  //console.log("collapse_idea_list set height to list_height: " + idea_list_height);
  list.height(idea_list_height);
  fix_list_overflow(list);
  //console.log("call adjust_lists from collapse_idea_list")
  //setTimeout(adjust_lists,400);
}

// make the lists fit in the display
var idea_list_height = 0;
function adjust_lists(){
  var lists_div = $('div#lists');
  var idea_lists = lists_div.find('div.idea_list').not('div.idea_list.expanded');
  // how many lists in a row?
  var cur_top = 0;
  var col_ctr = 0;
  idea_lists.each( 
    function(){
      var top = $(this).offset().top;
      if(cur_top == 0) cur_top = top;
      if(cur_top == top){
        ++col_ctr
      }else{
        return;
      }
    }
  );
  var num_rows = Math.ceil(idea_lists.size() / col_ctr);
  var row_height = lists_div.height() / num_rows;
  idea_list_height = row_height - 40;
  idea_lists.height(idea_list_height);
  //console.log("adjust_lists to set height to idea_list_height: " + idea_list_height);
  idea_lists.each( 
    function(){
      setTimeout( function(){ fix_list_overflow( this )}.bind($(this)), 100);
    }
  );
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


// Sort the order of the lists on the display
$('div#lists').sortable(
	{
		start: function(event,ui){
		  //console.log("LISTS WINDOW  start")
		},
		stop: function(event,ui){
			//console.log("LISTS WINDOW div#lists sortable stop")
			//if( !ui.item[0].nodeName.match(/li/i) ){
			//	var li = $('<li class="talking_point" id="' + ui.item.attr('tp_id') + '">' + ui.item.html() + 
			//		'<img src="/images/delete_icon_16.gif" title="Click to delete"></li>')
			//	ui.item.replaceWith(li);
			//	if( li.parent().find('li[id="' + li.attr('id') + '"]').size() > 1 ){
			//		li.html('<h3>Duplicate!</h3>');
			//		li.fadeOut(1400,function(){$(this).remove()})
			//	}
			//}else{
			//	var li = ui.item;
			//}
			//li.parent().find('li.talking_point[id="0"]').remove();
			//update_curated_tp_ids( $(this) );
		},
		receive: function(){
		  //console.log("LISTS WINDOW div.lists receive")
		},
		delay: 50,
		cursor: 'pointer'
		//,
		//placeholder: 'curated_list_placeholder'
	}
);

var idea_list_ctr = 1;
function int_to_letters(val){
  var str = '';
  var val_floor = Math.floor(val/26);
  var mod = ind = val%26;
  if(mod == 0){
    --val_floor;
    mod = 26;
  }
  if(val_floor>0){
    str += String.fromCharCode('A'.charCodeAt() + val_floor - 1);
  }
  
  str += String.fromCharCode('A'.charCodeAt() + mod - 1);
  return str;
}

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
  		},
  		stop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
  		  //console.log("1 LIST idea_list sortable stop " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
    		  ui.item.removeClass('live_talking_point ui-draggable');
          ui.item.addClass('idea');
        }else{
          // if there is only one copy of this idea currently
          var ques = $('<div class="move_or_copy_idea"><button>Move this idea to this list</button><button>Copy this idea to this list</button></div>');
          ui.item.css('background-color', '#f3973a').before(ques);
        }
  			//update_curated_tp_ids( $(this) );
  			if( idea_list.find('div.idea').size() == 0 ){
  			  idea_list.find('div.ideas').html(
  			    '<a href="#" class="remove_list">Remove empty list</a>');
  			}else{
  			  idea_list.find('a.remove_list').remove();
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
  		//over: function(event,ui){
  		//  var idea_list = $(this).closest('div.idea_list');
  		//  var theme = idea_list.find('p.theme').html();
  		//  
  		//  console.log("1 LIST idea_list sortable over " + theme);
  		//  //debugger
  		//},
  		//sort: function(event,ui){
  		//  var idea_list = $(this).closest('div.idea_list');
  		//  var theme = idea_list.find('p.theme').html();
  		//  
  		//  console.log("1 LIST idea_list sortable sort " + theme);
  		//  //debugger
  		//},
  		//activate: function(event,ui){
  		//  var idea_list = $(this).closest('div.idea_list');
  		//  var theme = idea_list.find('p.theme').html();
  		//  
  		//  console.log("1 LIST idea_list sortable activate " + theme);
  		//  //debugger
  		//},
  		receive: function(event,ui){
  		  var theme = $(this).closest('div.idea_list').find('p.theme').html();
  		  //console.log("1 LIST div.idea_list receive " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
  		    ui.item.hide(1000,
  		      function(){
  		        $(this).remove();
  		        $('div.incoming_ideas h3 span.cnt').html( $('div#live_talking_points div.live_talking_point').size() );
  		      }
  		    ); // remove original item
  		  }
  		  var par_list = $(this).closest('div.idea_list');
  		  if(par_list.hasClass('new_list')){
  		    //console.log("clone new_list and remove instr here");
  		    var new_list = par_list.clone();
  		    new_list.find('div.live_talking_point, div.idea').remove();
  		    par_list.find('p.instr').hide(1000,function(){$(this).remove()});
  		    par_list.removeClass('new_list');
  		    new_list.hide();
  		    par_list.after(new_list);
		      //console.log("call adjust_lists from make_idea_lists_sortable.receive")
  		    new_list.show(1000, function(){adjust_lists();});
  		    make_idea_lists_sortable( $('.sortable_ideas') );
  		    par_list.find('p.theme').html('List ' + int_to_letters(idea_list_ctr++) );
  		    setTimeout( function(){ fix_list_overflow( this )}.bind(par_list), 100);
  		  }else if(par_list.hasClass('misc_list')){
  		    par_list.find('p.instr').hide(1000,function(){$(this).remove()});
  		    setTimeout( function(){ fix_list_overflow( this )}.bind(par_list), 100);
  	    }
  		},
  		delay: 50,
  		cursor: 'pointer',
  		connectWith: '.sortable_ideas',
  		placeholder: 'curated_list_placeholder'
  	}
  );
}
make_idea_lists_sortable( $('.sortable_ideas') );

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
			$('div.incoming_ideas').width( '' );
			ui.helper.addClass('dragged_idea');
		},
		stop: function(event,ui){
		  //console.log("New Ideas stop");
		  dragging_new_idea = false;
		},
		
		connectToSortable: '.sortable_ideas',
		helper: 'clone'
	});
}

$('div.idea_list div.ideas').live('mouseenter mouseleave', function(event) {
	var list = $(this).closest('div.idea_list');
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

$('div.incoming_ideas div#live_talking_points').live('mouseenter mouseleave', 
  function(event) {
  	var incoming_ideas = $(this).closest('div.incoming_ideas');
    var ws = $('div.workspace');
    if (event.type == 'mouseenter') {
      if(dragging_new_idea)return;
      var last_idea = $('div.live_talking_point:last');
      if( last_idea.size() == 0 ) return;
      var inner = $('div#live_talking_points div.inner');
      var inner_bottom = inner.offset().top + inner.height();
      if(( $('div.live_talking_point:first').offset().top < 120 ) || (last_idea.offset().top + last_idea.height() > inner_bottom )){
        incoming_ideas.width( ws.width() - 100 );
      }
    } else {
      //console.log("incoming ideas mouseleave")
      incoming_ideas.width( '' );
    }
  }
);

$('div.idea_list img.edit').live('click',
  function(){
    console.log("edit the theme");
    return false;
  }
);


//$('a.new_live_talking_point').live('click', 
//	function(){
//		console.log("new_live_talking_point - add another form v1");
//		var tp = $('div.talking_point_block'); 
//		var tp_clone = tp.eq(0).clone();
//		if(tp.size() > 1){
//			$('a.new_live_talking_point').hide();
//
//		}else{
//
//		}
//		tp_clone.find('textarea').val('');
//		tp_clone.find('h3').html( tp_clone.find('h3').html().replace('Enter a ', 'Start a new ') );
//		tp.last().after(tp_clone)
//		return false;
//	}
//)




