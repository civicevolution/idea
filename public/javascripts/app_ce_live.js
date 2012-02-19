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
	  adjust_lists();
	}
}
$(window).resize(function(){
		try{  
			//setTimeout(live_resize,800);
		}catch(e){}
	}
);

setTimeout(live_resize,100);

$('span.role').before( $('a.test_mode') );
$('div.test_mode :submit').live('click',
	function(){
		setTimeout( "$('div.test_mode').hide(1500)", 1000 )
		console.log("hide form")
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
		  console.log("LISTS WINDOW  start")
		},
		stop: function(event,ui){
			console.log("LISTS WINDOW div#lists sortable stop")
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
		  console.log("LISTS WINDOW div.lists receive")
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
// Sort the ideas within a list
function make_idea_lists_sortable($idea_lists){
  $idea_lists.sortable(
  	{
  		start: function(event,ui){
  		  var theme = $(this).closest('div.idea_list').find('p.theme').html();
  		  console.log("1 LIST idea_list sortable start " + theme)
  			//$(this).find('img').removeClass('show');
  		},
  		stop: function(event,ui){
  		  var idea_list = $(this).closest('div.idea_list');
  		  var theme = idea_list.find('p.theme').html();
  		  console.log("1 LIST idea_list sortable stop " + theme);
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
  		},
  		receive: function(event,ui){
  		  var theme = $(this).closest('div.idea_list').find('p.theme').html();
  		  console.log("1 LIST div.idea_list receive " + theme);
  		  if(ui.item.hasClass('live_talking_point')){
  		    ui.item.hide(1000,function(){$(this).remove()}); // remove original item
  		  }
  		  var par_list = $(this).closest('div.idea_list');
  		  if(par_list.hasClass('new_list')){
  		    console.log("clone new_list and remove instr here");
  		    var new_list = par_list.clone();
  		    new_list.find('div.live_talking_point, div.idea').remove();
  		    par_list.find('p.instr').hide(1000,function(){$(this).remove()});
  		    par_list.removeClass('new_list');
  		    new_list.hide();
  		    par_list.after(new_list);
  		    new_list.show(1000, function(){adjust_lists();});
  		    make_idea_lists_sortable( $('.sortable_ideas') );
  		    par_list.find('p.theme').html('List ' + int_to_letters(idea_list_ctr++) );
  		  }else if(par_list.hasClass('misc_list')){
  		    par_list.find('p.instr').hide(1000,function(){$(this).remove()});
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

// make the lists fit in the display
function adjust_lists(){
  var lists_div = $('div#lists');
  var idea_lists = lists_div.find('div.idea_list');
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
  var list_height = row_height - 30;
  idea_lists.height(list_height);
  console.log("adjust_lists to height: " + list_height);
  
  
}



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
			// refresh your sortable -- so you can drop
			$('.sortable_ideas').sortable('refresh');
		},
		stop: function(event,ui){
		  console.log("New Ideas stop");
		},
		
		connectToSortable: '.sortable_ideas',
		helper: 'clone'
	});
}



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




// auto start the test  for 30 seconds
setTimeout( "$('div.test_mode :submit').click()", 2000);
setTimeout( "$('div.test_mode a.stop_test').click()", 30000);
