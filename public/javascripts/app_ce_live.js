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
	  
	}
}

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


// Sort the ideas within a list
$('.sortable_ideas').sortable(
	{
		start: function(event,ui){
		  console.log("1 LIST idea_list sortable start")
			//$(this).find('img').removeClass('show');
		},
		stop: function(event,ui){
		  console.log("1 LIST idea_list sortable stop");
		  if(ui.item.hasClass('live_talking_point')){
  		  ui.item.removeClass('live_talking_point ui-draggable');
        ui.item.addClass('idea');
      }
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
		receive: function(event,ui){
		  console.log("1 LIST div.idea_list receive")
		  if(ui.item.hasClass('live_talking_point')){
		    ui.item.remove(); // remove original item
		  }
		},
		delay: 50,
		cursor: 'pointer',
		connectWith: '.sortable_ideas',
		placeholder: 'curated_list_placeholder'
	}
);


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
